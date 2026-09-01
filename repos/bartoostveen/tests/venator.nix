{ lib, self, ... }:

let
  port = 8008;
  secret = "preSharedSecret";

  serverName = "venator:${toString port}";

  user = "alice";
  password = "verysecretpassword";
in
{
  name = "venator";

  nodes = {
    server = {
      imports = [ self.nixosModules.venator ];
      services.venator = {
        enable = true;
        configurePostgres = true;
        enableWrapper = true;
        settings = {
          server_name = serverName;
          registration.admin_pre_shared_secret = secret;
          database.max_open_connections = 255;
          listeners = [
            {
              inherit port;
              tls = false;
            }
          ];
        };
      };
      networking.firewall.allowedTCPPorts = [ port ];
    };

    client =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.curl
          (pkgs.writers.writePython3Bin "do_test" { libraries = [ pkgs.python3Packages.mautrix ]; } ''
            import asyncio

            from mautrix.client import Client
            from mautrix.types import EventType, RoomFilter, Filter


            async def main() -> None:
                # Connect to venator
                client = Client(
                    mxid="@${user}:${serverName}",
                    base_url="http://server:${toString port}",
                )

                # Log in as user alice
                await client.login(password="${password}")

                # Create a new room
                room_id = await client.create_room()
                print("Created room:", room_id)

                # Join the room
                await client.join_room_by_id(room_id)
                print("Joined room")

                # Send a message to the room
                received = asyncio.Event()
                msg = "Hello venator!"

                async def on_message(evt):
                    if (
                        evt.room_id != room_id
                        or evt.sender != client.mxid
                        or evt.type != EventType.ROOM_MESSAGE
                    ):
                        return

                    assert evt.content.body == msg
                    received.set()

                client.add_event_handler(EventType.ROOM_MESSAGE, on_message)
                sync_task = client.start(Filter(room=RoomFilter(rooms=[room_id])))

                await client.send_text(room_id, msg)

                # Sync until message is received
                await asyncio.wait_for(received.wait(), timeout=30)

                # Leave the room
                await client.leave_room(room_id)
                print("Left room")

                # Close the client
                client.stop()
                await sync_task


            if __name__ == "__main__":
                asyncio.run(main())
          '')
        ];
      };
  };

  testScript = ''
    start_all()
    with subtest("start venator"):
        server.wait_for_unit("venator.service")
        server.wait_for_open_port(${toString port})

    with subtest("create user"):
        server.succeed("venatorctl admin users create --admin ${user} ${password}")

    with subtest("reload config"):
        client.succeed("curl --fail -X POST -H \"Authorization: Bearer ${secret}\" http://server:${toString port}/_venator/v0/admin/reload-config")

    # TODO: not implemented yet
    # with subtest("ensure federation works"):
    #     client.succeed("curl --fail http://server:${toString port}/_matrix/federation/v1/version")

    with subtest("ensure sending messages is possible"):
        client.succeed("do_test >&2")
  '';

  meta.maintainers = with lib.maintainers; [
    bartoostveen
  ];
}
