{ mkBashCli, awscli }:

mkBashCli "krec2" "awscli alias junkbox" {} (mkCmd:
#mkBashCli "krec2" "awscli alias junkbox" (mkCmd:
    [
      (mkCmd "describe-instances" "List EC2 instances in a pretty table" { aliases = [ "din" ]; }''
        query='Reservations[].Instances[].[InstanceId, InstanceType, State.Name, PublicIpAddress, PrivateIpAddress, SubnetId, Placement.AvailabilityZone, Tags[?Key==`Name`] | [0].Value]'
        ${awscli}/bin/aws ec2 describe-instances --query "$query" --output table
      '')

      (mkCmd "lsr53" "List Route53 records in a pretty table" {} ''
        PATH=${awscli}/bin:$PATH
        domain=''${1?Must provide a domain to list its records}
        aws route53 list-hosted-zones-by-name --output text --query "HostedZones[?Name==\`$domain.\`].Id" | xargs aws route53 list-resource-record-sets --output table --query 'ResourceRecordSets[?Type==`CNAME`].Name' --hosted-zone-id
      '')

    ]
  )
