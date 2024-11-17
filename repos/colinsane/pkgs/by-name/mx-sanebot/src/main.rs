mod msg_handler;
mod parsing;

use std::env;

use futures::StreamExt as _;
use matrix_sdk::{
    Client,
    config::SyncSettings,
    deserialized_responses::SyncResponse,
};
use ruma::{
    OwnedRoomId,
    OwnedUserId,
    events::{
        AnySyncMessageLikeEvent,
        AnySyncTimelineEvent,
        SyncMessageLikeEvent,
        room::message::{
            MessageType,
            RoomMessageEventContent,
        },
    },
};
use ruma_client_api::{
    filter::FilterDefinition,
    sync::sync_events::v3::Filter,
};
use tokio::time::{sleep, Duration};

use msg_handler::MessageHandler;

#[derive(Clone)]
struct Runner {
    // this is actually a *handle* to the client (Arc).
    client: Client,
}

/// this encodes the specific set of Matrix events i might ever care about.
#[derive(Debug)]
enum Event {
    /// i was invited to the given room
    Invitation(OwnedRoomId),
    /// i see a message in the given room, from the given user
    Message(OwnedRoomId, OwnedUserId, String),
}

/// some action i might do, usually in response to an Event.
#[derive(Debug)]
enum Action {
    AcceptInvite(OwnedRoomId),
    SendMessage(OwnedRoomId, String /* text */, Option<String> /* html */),
}

impl Runner {
    async fn login(
        homeserver: &str,
        username: &str,
        password: &str,
    ) -> anyhow::Result<Self> {
        // TODO: look into caching the messages somewhere on disk (sled; indexeddb)
        let client = Client::builder()
            .homeserver_url(homeserver)
            .sled_store("/home/colin/mx-sanebot", None)?
            .build()
            .await?;
        println!("client built");
        client.login_username(&username, &password).initial_device_display_name("sanebot")
            .initial_device_display_name("sanebot")
            .send()
            .await?;

        println!("logged in as {username}");

        Ok(Runner { client })
    }

    async fn event_loop(&self) -> anyhow::Result<()> {
        // event types if i only care about monitoring invites
        let types_for_invites = [
            "m.room.member".to_owned(), // StrippedRoomMemberEvent
        ];
        // event types i care about during normal operation
        let types_for_all = [
            "m.room.member".to_owned(), // StrippedRoomMemberEvent
            "m.room.message".to_owned(), // RoomMessageEvent
        ];
        // always ignore messages from self
        let not_senders = [ self.client.user_id().unwrap().to_owned() ];

        let build_sync_settings = |token| {
            let mut filter = FilterDefinition::default();
            filter.room.timeline.not_senders = &not_senders;
            filter.room.timeline.types = Some(match token {
                None => &types_for_invites,
                Some(_) => &types_for_all,
            });
            let mut settings = SyncSettings::default().filter(
                Filter::FilterDefinition(filter)
            );
            if let Some(t) = token {
                settings = settings.token(t);
            }
            settings
        };

        // initial sync during which i handle only room invites, but ignore any messages
        // from before now. this means i ignore messages from when i was offline, but in
        // doing so do not need to worry about double responses.
        let settings = build_sync_settings(None);
        let response = self.client.sync_once(settings).await.unwrap();
        let next_token = response.next_batch.clone();
        self.act_on_sync_response(response).await;
        println!("sync'd");

        let settings = build_sync_settings(Some(next_token));
        let mut sync_stream = Box::pin(
            self.client.sync_stream(settings)
            .await
        );
        while let Some(Ok(response)) = sync_stream.next().await {
            // println!("handling sync responses");
            self.act_on_sync_response(response).await;
        }

        Ok(())
    }

    fn parse_sync_response<'a>(&'a self, response: SyncResponse) -> impl Iterator<Item=Event> + 'a {
        let events_from_invited_rooms = response.rooms.invite
            .into_iter()
            .map(|(room_id, _room)| {
                self.parse_room_invite(room_id)
            });
        let events_from_joined_rooms = response.rooms.join
            .into_iter()
            .flat_map(move |(room_id, room)| {
                room.timeline.events.into_iter().flat_map(move |e| match e.event.deserialize() {
                    Ok(event) => self.parse_timeline_event(room_id.clone(), event),
                    Err(_) => None,
                })
            });
        events_from_invited_rooms.chain(events_from_joined_rooms)
    }

    async fn act_on_sync_response(&self, response: SyncResponse) {
        for event in self.parse_sync_response(response) {
            self.act_on_event(event).await;
        }
    }

    fn parse_room_invite(&self, room_id: OwnedRoomId) -> Event {
        println!("Received invite {:?}", room_id);
        Event::Invitation(room_id)
    }

    fn parse_timeline_event(&self, room_id: OwnedRoomId, event: AnySyncTimelineEvent) -> Option<Event> {
        println!("Considering timeline event {:?}", event);
        let sender = event.sender();
        // protect against a bad sync filter that would cause me to see my own events
        assert_ne!(Some(sender), self.client.user_id());

        match event {
            AnySyncTimelineEvent::MessageLike(ref msg_like) => match msg_like {
                AnySyncMessageLikeEvent::RoomMessage(SyncMessageLikeEvent::Original(room_msg)) => match room_msg.content.msgtype {
                    MessageType::Text(ref text_msg) => Some(
                        Event::Message(room_id, sender.to_owned(), text_msg.body.clone())
                    ),
                    _ => None,
                },
                _ => None,
            },
            _ => None,
        }
    }

    async fn act_on_event(&self, event: Event) {
        self.perform_action(self.map_event_to_action(event)).await;
    }

    fn map_event_to_action(&self, event: Event) -> Action {
        println!("processing event {event:?}");
        match event {
            Event::Invitation(room_id) => Action::AcceptInvite(room_id),
            Event::Message(room_id, _sender_id, body) => {
                let resp = MessageHandler.on_msg(&body);
                Action::SendMessage(room_id, resp.to_string(), resp.html())
            }
        }
    }

    async fn perform_action(&self, action: Action) {
        println!("performing action: {action:?}");
        match action {
            Action::AcceptInvite(room_id) => {
                // matrix example claims:
                // """
                //   The event handlers are called before the next sync begins, but
                //   methods that change the state of a room (joining, leaving a room)
                //   wait for the sync to return the new room state so we need to spawn
                //   a new task for them.
                // """
                let room = self.client.get_invited_room(&room_id).unwrap();
                tokio::spawn(async move {
                    let mut delay = 2;

                    while let Err(err) = room.accept_invitation().await {
                        // retry autojoin due to synapse sending invites, before the
                        // invited user can join for more information see
                        // https://github.com/matrix-org/synapse/issues/4345
                        eprintln!("Failed to join room {} ({err:?}), retrying in {delay}s", room.room_id());

                        sleep(Duration::from_secs(delay)).await;
                        delay *= 2;

                        if delay > 3600 {
                            eprintln!("Can't join room {} ({err:?})", room.room_id());
                            break;
                        }
                    }
                    println!("Successfully joined room {}", room.room_id());
                });
            }
            Action::SendMessage(room_id, text, html) => {

                let room = self.client.get_joined_room(&room_id).unwrap();
                let resp_content = match html {
                    None => RoomMessageEventContent::text_plain(&text),
                    Some(html) => RoomMessageEventContent::text_html(&text, &html),
                };
                room.send(resp_content, None).await.unwrap();
            }
        }
    }
}


#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let password = env::var("SANEBOT_PASSWORD").unwrap_or("password".into());
    let runner = Runner::login("https://uninsane.org", "sanebot", &*password).await?;
    let result = runner.event_loop().await;
    println!("exiting");
    result
}
