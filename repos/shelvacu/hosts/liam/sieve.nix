{
  pkgs,
  lib,
  config,
  vaculib,
  ...
}:
let
  inherit (builtins)
    isString
    isList
    length
    head
    all
    isInt
    isAttrs
    isFloat
    isBool
    ;
  inherit (lib)
    concatStrings
    concatStringsSep
    splitString
    match
    replaceStrings
    reverseList
    elemAt
    mapAttrsToList
    ;
  mapConcat = f: xs: concatStrings (map f xs);
  mapConcatSep =
    sep: f: xs:
    concatStringsSep sep (map f xs);
  mapConcatLines = f: xs: mapConcatSep "\n" f xs;
  isListWhere = xs: f: (isList xs) && (all f xs);
  stringOrList = val: (isString val) || ((isListWhere val isString) && (length val) > 0);
  listify = val: if isList val then val else [ val ];
  is_match = regex: s: (match regex s) != null;
  is_not_match = regex: s: !(is_match regex s);
  only_printable_ascii = s: is_match "[ -~\r\n]*" s;
  has_vars = s: lib.hasInfix ("$" + "{") s;
  sieve_raw_escape_string =
    s:
    if !only_printable_ascii s then
      builtins.trace s throw "s failed only_printable_ascii check"
    else
      replaceStrings [ ''"'' ''\'' "\n" "\r" ] [ ''\"'' ''\\'' ''\n'' ''\r'' ] s;
  sieve_encode_string =
    {
      allow_vars,
      for_debug_comment,
      with_quotes,
    }:
    s:
    assert isString s;
    assert allow_vars || for_debug_comment || (!has_vars s);
    let
      a = sieve_raw_escape_string s;
      b = if for_debug_comment then replaceStrings [ ''*/'' ] [ ''*\/'' ] a else a;
      res = if with_quotes then ''"${b}"'' else b;
    in
    res;
  sieve_quote_string = sieve_encode_string {
    allow_vars = false;
    for_debug_comment = false;
    with_quotes = true;
  };
  sieve_quote_string_with_interp = sieve_encode_string {
    allow_vars = true;
    for_debug_comment = false;
    with_quotes = true;
  };
  is_valid_long_ident = is_match "[a-z_][a-z0-9_]*";
  is_number_ident = is_match "[0-9]*";
  is_valid_ident = s: (is_valid_long_ident s) || (is_number_ident s);
  interp =
    ident:
    assert isString ident;
    assert is_valid_ident ident;
    "$" + "{${ident}}";
  dest = "envelope_to";
  dest_domain = "envelope_to_domain";
  set_envelope = ''
    #set_envelope START
    if header :index 1 :matches "X-Envelope-To" "*" {
      set ${sieve_quote_string dest} "''${1}";
    }
    if header :index 1 :matches "X-Envelope-To" "*@*" {
      set ${sieve_quote_string dest_domain} "''${2}";
    }
    #set_envelope END
  '';
  envelope_is =
    key:
    assert stringOrList key;
    ''string :is "${interp dest}" ${sieve_encode key}'';
  envelope_matches =
    key:
    assert stringOrList key;
    ''string :matches "${interp dest}" ${sieve_encode key}'';
  envelope_domain_is = key: ''string :is "${interp dest_domain}" ${sieve_quote_string key}'';
  sieve_encode_list =
    xs:
    assert isListWhere xs isString;
    "[ ${mapConcatSep ", " sieve_encode xs} ]";
  sieve_encode =
    val:
    if isString val then
      sieve_quote_string val
    else if isList val then
      sieve_encode_list val
    else
      assert "dunno what to do with this";
      null;
  sieve_debug_list = xs: "[ ${mapConcat (s: (sieve_debug s) + " ") xs}]";
  sieve_debug_attrs =
    attrs:
    let
      toPairStr = name: val: "${sieve_debug name} = ${sieve_debug val}; ";
      pairStrs = mapAttrsToList toPairStr attrs;
      pairsStr = concatStrings pairStrs;
    in
    "{ ${pairsStr}}";
  sieve_debug =
    val:
    if isString val then
      sieve_encode_string {
        allow_vars = true;
        for_debug_comment = true;
        with_quotes = true;
      } val
    else if (isInt val) || (isFloat val) then
      toString val
    else if (isBool val) then
      (if val then "true" else "false")
    else if isNull val then
      "null"
    else if isList val then
      sieve_debug_list val
    else if isAttrs val then
      sieve_debug_attrs val
    else
      assert "dunno what to do with this";
      null;
  is_flagish =
    flag_name:
    let
      # escape_all = map lib.escapeRegex;

      # all from https://datatracker.ietf.org/doc/html/rfc9051#name-formal-syntax
      # resp-specials = escape_all [ "]" ];
      # DQUOTE = ''"'';
      # quoted-specials = escape_all [ DQUOTE "\\" ];
      # list-wildcards = escape_all [ "%" "*" ];
      # CTL = something; # 0x00 thru 0x1F, and 0x7F
      # SP = escape_all [ " " ];
      # atom-specials = (escape_all [ "(" ")" "{" ]) ++ [ SP CTL list-wildcards quoted-specials resp-specials ];
      # " "  0x20 !allowed
      # "!"  0x21 ok
      # "\"" 0x22 !allowed
      # "#"  0x23 ok
      # "$"  0x24 ok
      # "%"  0x25 !allowed
      # "&"  0x26 ok
      # "'"  0x27 ok
      # "("  0x28 !allowed
      # ")"  0x29 !allowed
      # "*"  0x2a !allowed
      # "+"  0x2b ok
      # ...
      # "Z"  0x5a ok
      # "["  0x5b !allowed
      # "\\" 0x5c !allowed
      # "]"  0x5d ok
      # "^"  0x5e ok
      # ...
      # "z"  0x7a ok
      # "{"  0x7b !allowed
      # "|"  0x7c ok
      # "}"  0x7d ok
      # "~"  0x7e ok
      # DEL  0x7f !allowed
      # ATOM-CHAR = something; # "any CHAR except atom-specials"
      ATOM-CHAR = ''[]!#$&'+-Z^-z|}~]'';
      atom = "${ATOM-CHAR}+";
      flag-keyword = ''\$MDNSent|\$Forwarded|\$Junk|\$NotJunk|\$Phishing|(${atom})'';
      flag-extension = ''\\(${atom})'';
      flag = ''\\Answered|\\Flagged|\\Deleted|\\Seen|\\Draft|(${flag-keyword})|(${flag-extension})'';
    in
    (isString flag_name) && ((builtins.match flag flag_name) != null);
  known_flags = rec {
    seen = ''\Seen'';
    read = seen;
  };
  pure_flags_impl =
    flags: conditions:
    assert isListWhere flags isString;
    assert isListWhere conditions isString;
    assert (length flags) > 0;
    assert (length conditions) > 0;
    let
      argAttrs = { inherit flags conditions; };
      firstFlag = head flags;
      combined_condition = if (length conditions) == 1 then head conditions else (allof conditions);
    in
    ''
      # pure_flags ${sieve_debug argAttrs};
      removeflag ${sieve_quote_string firstFlag};
      if ${combined_condition} {
        ${record_action "pure_flags ${concatStringsSep " " flags}"}
        ${concatStringsSep "\n" (map (flag: ''addflag ${sieve_quote_string flag};'') flags)}
      }
      # pure_flags end
    '';
  pure_flags =
    flags: conditions:
    assert stringOrList flags;
    assert stringOrList conditions;
    pure_flags_impl (listify flags) (listify conditions);
  exists_impl =
    headers:
    assert isListWhere headers isString;
    if headers == [ ] then
      "/* exists START: called with empty array */ false /* exists END */"
    else
      "/* exists START */ exists ${sieve_encode_list headers} /* exists END */";
  exists =
    headers:
    assert stringOrList headers;
    exists_impl (listify headers);
  header_generic =
    match_kind: header_s: match_es:
    assert stringOrList header_s;
    assert stringOrList match_es;
    ''/* header_generic START */ header ${match_kind} ${sieve_encode header_s} ${sieve_encode match_es} /* header_generic END */'';
  header_matches = header_generic ":matches";
  header_is = header_generic ":is";
  subject_generic = match_kind: match_es: header_generic match_kind "Subject" match_es;
  subject_matches = subject_generic ":matches";
  subject_is = subject_generic ":is";
  environment_generic =
    match_kind: environment_name_s: match_es:
    assert stringOrList environment_name_s;
    assert stringOrList match_es;
    "environment ${match_kind} ${sieve_encode environment_name_s} ${sieve_encode match_es}";
  environment_matches = environment_generic ":matches";
  environment_is = environment_generic ":is";
  from_is =
    addr_list:
    assert stringOrList addr_list;
    ''/* from_is START */ address :is :all "From" ${sieve_encode addr_list} /* from_is END */'';
  from_matches =
    addr_list:
    assert stringOrList addr_list;
    ''/* from_is START */ address :matches :all "From" ${sieve_encode addr_list} /* from_is END */'';
  var_is =
    var_name: rhs:
    assert isString var_name;
    assert stringOrList rhs;
    ''string :is "''${${var_name}}" ${sieve_encode rhs}'';
  var_is_true = var_name: var_is var_name "1";
  var_is_false = var_name: not (var_is_true var_name);
  has_flag =
    flag_name:
    assert isString flag_name;
    assert is_flagish flag_name; # no spaces allowed in flag names
    ''hasflag :is ${sieve_encode flag_name}'';
  set_with_interp =
    var_name: new_val:
    assert isString var_name;
    assert is_valid_ident var_name;
    assert isString new_val;
    "set ${sieve_encode var_name} ${sieve_quote_string_with_interp new_val};";
  set =
    var_name: new_val:
    assert isString var_name;
    assert is_valid_ident var_name;
    assert isString new_val;
    "set ${sieve_encode var_name} ${sieve_encode new_val};";
  set_bool_var =
    var_name: bool_val:
    assert isBool bool_val;
    set var_name (if bool_val then "1" else "0");
  over_test_list =
    name: test_list:
    assert isListWhere test_list isString;
    ''
      ${name}(
      ${concatStringsSep ",\n" test_list}
      )
    '';
  anyof = over_test_list "anyof";
  allof = over_test_list "allof";
  not = test: "not ${test}";
  record_action =
    action_desc:
    assert isString action_desc;
    ''addheader "X-Vacu-Action" ${sieve_encode action_desc};'';
  fileinto =
    folder:
    assert isString folder;
    ''
      ${record_action "fileinto ${folder}"}
      fileinto :create ${sieve_encode folder};
    '';
  ihave =
    extension_name_s:
    assert stringOrList extension_name_s;
    "ihave ${sieve_encode extension_name_s}";
  # email_filters = map (e: ''
  #   elsif ${envelope_is e} { # item of email_filters
  #     ${record_action "email_filters fileinto ${mk_email_folder_name e}"}
  #     fileinto :create ${sieve_quote_string (mk_email_folder_name e)};
  #   }
  # '') email_folders;
  # domain_filters = map (d: ''
  #   elsif ${envelope_domain_is d} { # item of domain_filters
  #     ${record_action "domain_filters fileinto ${mk_domain_folder_name d}"}
  #     fileinto :create ${sieve_quote_string (mk_domain_folder_name d)};
  #   }
  # '') domain_folders;
  set_from =
    {
      condition,
      var,
      default ? "-",
      warn_if_unset ? false,
    }@args:
    ''
      # set_from ${sieve_debug args}
      if ${condition} {
        ${set_with_interp var (interp "1")}
      }
      else {
        ${lib.optionalString warn_if_unset (
          maybe_debug "info: Could not set ${var} from condition ${condition}, setting to default(${default})"
        )}
        ${set var default}
      }
      # set_from END
    '';
  set_var_from_environment =
    item: var:
    ''
      # set_var_from_environment
    ''
    + set_from {
      condition = ''environment :matches ${sieve_quote_string item} "*"'';
      inherit var;
    };
  maybe_debug = msg: ''
    if ${ihave "vnd.dovecot.debug"} {
      debug_log ${sieve_quote_string_with_interp msg};
    }
  '';
  # trimmed down from https://pages.ebay.com/securitycenter/security_researchers_eligible_domains.html
  ebay_domains = vaculib.listOfLines { } ''
    ebay.com
    ebay.co.uk
    ebay.com.au
    ebay.de
    ebay.ca
    ebay.fr
    ebay.it
    ebay.es
    ebay.at
    ebay.ch
    ebay.com.hk
    ebay.com.sg
    ebay.com.my
    ebay.in
    ebay.ph
    ebay.ie
    ebay.pl
    ebay.be
    ebay.nl
    ebay.cn
    ebay.com.tw
    ebay.co.jp
    ebaythailand.co.th
  '';
  sieve_text = ''
    require [
      "fileinto",
      "mailbox",
      "imap4flags",
      "editheader",
      "environment",
      "variables",
      "date",
      "index",
      "ihave"
    ];

    if ${
      allof [
        (ihave "imapsieve")
        (environment_matches "imap.user" "*")
        (environment_matches "location" "MS")
        (environment_matches "phase" "post")
      ]
    } {
      ${set_bool_var "in_imap" true}
    } else {
      ${set_bool_var "in_imap" false}
    }

    if ${var_is_true "in_imap"} {
      if ${
        not (allof [
          (environment_is "imap.cause" [
            "APPEND"
            "COPY"
            ""
          ])
          (environment_is "imap.mailbox" [
            "MagicRefilter"
            ""
          ])
        ])
      } {
        ${maybe_debug "NOT doing anything cuz imap.cause and/or imap.mailbox isn't right"}
        stop;
      }
    }

    ${set_envelope}
    ${set_var_from_environment "location" "env_location"}
    ${set_var_from_environment "phase" "env_phase"}
    ${set_var_from_environment "imap.user" "env_imap_user"}
    ${set_var_from_environment "imap.email" "env_imap_email"}
    ${set_var_from_environment "imap.cause" "env_imap_cause"}
    ${set_var_from_environment "imap.mailbox" "env_imap_mailbox"}
    ${set_var_from_environment "imap.changedflags" "env_imap_changedflags"}
    ${set_from {
      condition = ''currentdate :matches "iso8601" "*"'';
      var = "datetime";
    }}
    ${set_with_interp "sieved_message" ''at ''${datetime} by ${config.vacu.versionId} loc ''${env_location} phase ''${env_phase} user ''${env_imap_user} email ''${env_imap_email} cause ''${env_imap_cause} mailbox ''${env_imap_mailbox} changedflags ''${env_imap_changedflags} envelope ''${dest}''}
    ${maybe_debug ''X-Vacu-Sieved: ''${sieved_message}''}

    if ${ihave "envelope"} {
      if envelope :all :matches "to" "*@*" {
        ${set_with_interp "userfor" (interp "1")}
      } else {
        error "i dunno what to do, theres no envelope";
      }
    }
    elsif ${var_is_true "in_imap"} {
      ${set_with_interp "userfor" (interp "env_imap_user")}
    }
    else {
      error "dont have envelope or imapsieve, dunno what to do";
    }

    if ${var_is "userfor" "shelvacu"} {
      addheader "X-Vacu-Sieved" "''${sieved_message}";
      removeflag "not-spamish";
      removeflag "orders";
      removeflag "banking";
      removeflag "banking-statements";
      removeflag "banking-transactions";
      removeflag "A";
      removeflag "B";
      removeflag "B.subscriptions";
      removeflag "C";
      removeflag "D";

      ${pure_flags [ "to-a" "A" ] (envelope_matches "*-to-a@shelvacu.com")}
      ${pure_flags [ "to-b" "B" ] (envelope_matches "*-to-b@shelvacu.com")}
      ${pure_flags [ "to-c" "C" ] (envelope_matches "*-to-c@shelvacu.com")}
      ${pure_flags [ "to-d" "D" ] (envelope_matches "*-to-d@shelvacu.com")}
      ${pure_flags [ "ml" "B.subscriptions" ] (envelope_matches "*-ml@shelvacu.com")}

      ${pure_flags [ "dmarc-reports" ] (envelope_is "dmarc-rua@shelvacu.com")}
      ${pure_flags [ "coolppl" "A" ] (from_matches [
        #todo: do this without exposing friends' email addresses
        "*@mio19.uk"
        "*@uninsane.org"
        "*@nettika.cat"
        "*@mooooo.ooo"
      ])}
      ${pure_flags [ "wells-fargo" "banking" ] (envelope_is "wf-primary@shelvacu.com")}
      ${pure_flags
        [ "wells-fargo-transactions" "banking-transactions" "B" ]
        [
          (has_flag "wells-fargo")
          (subject_matches [
            "You just got paid!"
            "Wells Fargo card purchase exceeded preset amount"
            "You made a payment"
            "You made a credit card purchase of *"
            "Your card wasn't present for a purchase"
            "Account update"
            "You've earned cash back from My Wells Fargo Deals"
            "Confirmation of your Wells Fargo Rewards redemption"
            "You sent money with Zelle(R)"
          ])
        ]
      }
      ${pure_flags
        [ "wells-fargo-statements" "banking-statements" "C" ]
        [
          (has_flag "wells-fargo")
          (subject_matches [
            "Your statement for credit card account *"
            "Your statement for account *"
          ])
        ]
      }
      ${pure_flags
        [ "wells-fargo-action-required" "A" ]
        [
          # wf is actually careful about saying action required
          (has_flag "wells-fargo")
          (subject_matches "Action Required: *")
        ]
      }
      ${pure_flags
        [ "wells-fargo-misc" "A" ]
        [
          (has_flag "wells-fargo")
          (not (has_flag "wells-fargo-transactions"))
          (not (has_flag "wells-fargo-statements"))
          (not (has_flag "wells-fargo-action-required"))
        ]
      }
      ${pure_flags [ "chase" "banking" ] (envelope_is "chase@shelvacu.com")}
      ${pure_flags
        [ "chase-transactions" "banking-transactions" "B" ]
        [
          (has_flag "chase")
          (subject_matches [
            "Your * payment is scheduled"
            "You made a * transaction with *"
            "Your * transaction with *"
            "Chase security alert: You signed in with a new device"
          ])
        ]
      }
      ${pure_flags
        [ "chase-statements" "banking-statements" "C" ]
        [
          (has_flag "chase")
          (subject_matches [
            "Your credit card statement is available"
          ])
        ]
      }
      ${pure_flags
        [ "chase-spam" "D" ]
        [
          (has_flag "chase")
          (anyof [
            (header_is "From" "Chase Credit Journey <no.reply.alerts@chase.com>")
            (subject_is [
              "Review your recent activity"
              "Good news: You may qualify for a credit line increase!"
              "Your Chase card is available to use with Paze - Activate now!"
            ])
          ])
        ]
      }
      ${pure_flags [ "experian" ] (envelope_is "fbyjemby@shelvacu.com")}
      ${pure_flags
        [ "experian-spam" "D" ]
        [
          (has_flag "experian")
          (subject_matches [
            "*, your FICO* Score has been updated"
            "Your monthly account statement is here, *"
          ])
        ]
      }
      ${pure_flags
        [ "paypal" "banking" ]
        [
          # can't go purely on envelope, because paypal loves to give my email to every merchant I interact with
          (envelope_is "paypal@shelvacu.com")
          (from_matches [
            "*@paypal.com"
            "*@*.paypal.com"
          ])
        ]
      }
      ${pure_flags
        [ "paypal-transactions" "banking-transactions" "B" ]
        [
          (has_flag "paypal")
          (subject_matches [
            "Receipt for your payment to *"
            "*: $* USD"
            "*: $* CAD"
            "*: kr * SEK"
            "You authorized a payment to *"
            "You sent an automatic payment to *"
            "Review your new automatic payment setup for *"
            "You have a refund from *"
          ])
        ]
      }
      ${pure_flags
        [ "paypal-statements" "banking-statements" "C" ]
        [
          (has_flag "paypal")
          (subject_matches [
            "*, your * account statement is available."
          ])
        ]
      }

      ${pure_flags [ "usps-id" ] (envelope_is "usps-id@shelvacu.com")}
      ${pure_flags
        [ "usps-expected-delivery" "C" ]
        [
          (has_flag "usps-id")
          (subject_matches "USPS* Expected Delivery *")
        ]
      }
      ${pure_flags
        [ "amazon-ignore" "C" ]
        [
          (envelope_is "amznbsns@shelvacu.com")
          (subject_matches [
            "Your Amazon.com order has shipped*"
            "Your Amazon.com order of * has shipped!"
          ])
        ]
      }
      ${pure_flags
        [ "bandcamp-ignore" "C" ]
        [
          (envelope_is "bandcamp@shelvacu.com")
          (subject_matches [
            "* just announced a listening party on Bandcamp"
            "New items from *"
            "Starting in *"
            "New from *"
          ])
        ]
      }
      ${pure_flags
        [ "bandcamp-not-ignore" "B.subscriptions" ]
        [
          (envelope_is "bandcamp@shelvacu.com")
          ''not hasflag "bandcamp-ignore"''
        ]
      }
      ${pure_flags [ "ika-ignore" "D" ] (envelope_is "ika@dis8.net")}
      ${pure_flags
        [ "ally-statement" "C" ]
        [
          (envelope_is "ally@shelvacu.com")
          (subject_is "Your latest statement is ready to view.")
        ]
      }

      ${pure_flags "bloomberg" (envelope_is "bloomberg@shelvacu.com")}

      ${pure_flags
        [ "money-stuff" "not-spamish" ]
        [
          (envelope_is "bloomberg@shelvacu.com")
          ''header :matches "From" "\"Matt Levine\" *"''
        ]
      }

      ${pure_flags
        [ "money-stuff-podcast" "D" known_flags.read ]
        [
          (has_flag "money-stuff")
          (subject_matches "Money Stuff: The Podcast:*")
        ]
      }

      ${pure_flags
        [ "money-stuff-not-podcast" "B.subscriptions" ]
        [
          (has_flag "money-stuff")
          (not (has_flag "money-stuff-podcast"))
        ]
      }

      ${pure_flags [ "git" "not-spamish" "B" ] (exists [
        "X-GitHub-Reason"
        "X-GitLab-Project"
      ])}
      ${pure_flags [ "git-uninsane" "git" "not-spamish" "B" ] (envelope_is "git-uninsane@shelvacu.com")}
      ${pure_flags [ "github" "git" "not-spamish" "B" ] (header_matches "List-Id" "*<*.github.com>")}
      ${pure_flags [ "mailing-list-by-envelope" "not-spamish" "B" ] (
        envelope_matches "*-ml@shelvacu.com"
      )}
      
      ${pure_flags [ "discourse" "not-spamish" "B" ] (exists "X-Discourse-Post-Id")}
      ${pure_flags [ "agora" "not-spamish" ] (envelope_is "agora@shelvacu.com")}
      ${pure_flags [ "postgres-list" "not-spamish" ] (
        header_matches "List-Id" "<*.lists.postgresql.org>"
      )}
      ${pure_flags [ "secureaccesswa" "not-spamish" "A" ] (from_is "help@secureaccess.wa.gov")}
      ${pure_flags [ "letsencrypt-mailing-list" "not-spamish" "B" ] (
        envelope_is "lets-encrypt-mailing-list@shelvacu.com"
      )}
      ${pure_flags [ "jmp-news" "not-spamish" "B" ] (header_matches "List-Id" "*<jmp-news.soprani.ca>")}
      ${pure_flags
        [ "tf2wiki" "not-spamish" "B" ]
        [
          (envelope_is "tf2wiki@shelvacu.com")
          (from_is "noreply@wiki.teamfortress.com")
        ]
      }

      ${pure_flags "gmail-fwd" (envelope_is "gmailfwd-fc2e10bec8b2@shelvacu.com")}
      ${pure_flags [ "ebay" "orders" ] (envelope_is "ebay@shelvacu.com")}
      ${pure_flags
        [ "ebay-delivered" "B" ]
        [
          (has_flag "ebay")
          (subject_matches [
            "*ORDER DELIVERED: *"
          ])
        ]
      }
      ${pure_flags
        [ "ebay-message" "B" ]
        [
          (has_flag "ebay")
          (from_matches (map (domain: "*@members.${domain}") ebay_domains))
        ]
      }
      ${pure_flags
        [ "ebay-offer" "B" ]
        [
          (has_flag "ebay")
          (subject_matches [
            "You have an offer from the seller, *"
            "You saw it at *, but the seller is now offering *"
          ])
        ]
      }
      ${pure_flags
        [ "ebay-order-update" "C" ]
        [
          (has_flag "ebay")
          (subject_matches [
            "Out for delivery: *"
            "*DELIVERY UPDATE: *"
            "*Order update: *"
            "EARLY DELIVERY UPDATE: *"
            "Important information regarding your Global Shipping Program transaction *" # ebay: "important information! your order is being shipped." why did you say this was ""important""???
            "Your package is now with *"
            "*Order confirmed: *"
            "Your order is confirmed"
            "Your order is in!"
            "*An update on your order"
          ])
        ]
      }
      ${pure_flags
        [ "ebay-bid-ongoing-notification" "C" ]
        [
          (has_flag "ebay")
          (subject_matches [
            "Michael, your bid for * is winning"
            "* just got a new bid."
          ])
        ]
      }
      ${pure_flags
        [ "ebay-feedback" "D" ]
        [
          (has_flag "ebay")
          (subject_matches "Please provide feedback for your eBay items")
        ]
      }
      ${pure_flags [ "royal-mail" "orders" ] (from_is "no-reply@royalmail.com")}
      ${pure_flags
        [ "royal-mail-delivered" "B" ]
        [
          (has_flag "royal-mail")
          (subject_matches "Your Royal Mail parcel has been delivered")
        ]
      }
      ${pure_flags
        [ "royal-mail-on-the-way" "D" ]
        [
          (has_flag "royal-mail")
          (subject_matches "Your Royal Mail parcel is on its way")
        ]
      }
      ${pure_flags [ "aliexpress" "orders" ] (anyof [
        (from_is [
          "transaction@notice.aliexpress.com"
          "aliexpress@notice.aliexpress.com"
        ])
        (envelope_is "ali@shelvacu.com")
      ])}
      ${pure_flags
        [ "aliexpress-delivered" "B" ]
        [
          (has_flag "aliexpress")
          (from_is "transaction@notice.aliexpress.com")
          (subject_matches "Order * has been signed for")
        ]
      }
      ${pure_flags
        [ "aliexpress-misc" "C" ]
        [
          (has_flag "aliexpress")
          (not (has_flag "aliexpress-delivered"))
        ]
      }
      ${pure_flags [ "brandcrowd" "D" ] (envelope_is "brandcrowd@shelvacu.com")}
      ${pure_flags [ "cpapsupplies" "D" ] (envelope_is "cpapsupplies@shelvacu.com")}
      ${pure_flags [ "genshin" "D" ] (envelope_is "genshin@shelvacu.com")}
      ${pure_flags [ "jork" "B" ] (envelope_is "jork@shelvacu.com")}
      ${pure_flags [ "patreon" "not-spamish" ] (envelope_is "patreon@shelvacu.com")}
      ${pure_flags
        [ "patreon-post" "B.subscriptions" ]
        [
          (has_flag "patreon")
          (header_is "X-Mailgun-Tag" [
            "template_newsletterpostcontrol"
            "template_newsletterpost"
          ])
        ]
      }
      ${pure_flags
        [ "patreon-free-member-digest" "D" ]
        [
          (has_flag "patreon")
          (header_is "X-Mailgun-Tag" "template_freememberdigest")
        ]
      }
      ${pure_flags
        [ "patreon-other" "B" ]
        [
          (has_flag "patreon")
          (not (has_flag "patreon-post"))
          (not (has_flag "patreon-free-member-digest"))
        ]
      }
      ${pure_flags
        [ "subscribestar-update" "B.subscriptions" ]
        [
          (envelope_is "subscribestar@shelvacu.com")
          (subject_matches "New post from * on SubscribeStar.com")
        ]
      }
      ${pure_flags [ "rsb" "B" ] (from_is "support@rapidseedbox.com")}
      ${pure_flags [ "fresh-avocado-dis8" "D" ] (envelope_is "fresh.avocado@dis8.net")}
      ${pure_flags [ "discord" "A" ] (envelope_matches "discord@*")}
      ${pure_flags [ "za-sa" "D" ] (from_matches [
        "*@*.sa.com"
        "*@*.za.com"
      ])}
      ${pure_flags [ "localdomain" "D" ] (from_matches [
        "*@*.local"
        "*@*.localdomain"
      ])}
      ${pure_flags [ "helium" "D" ] (envelope_is "creepyface@dis8.net")}
      ${pure_flags [ "sharkmood" "C" ] (envelope_is "sharkmood@dis8.net")}
      ${pure_flags [ "im-not-district-158" "D" ] (envelope_is [
        "khamar.anderson@dis8.net"
        "pbooth@dis8.net"
        "sgaylor@dis8.net"
      ])}
      ${pure_flags [ "next-level-burger" "D" ] (header_matches "From" "*Next Level Burger*")}
      ${pure_flags [ "lyft" "D" ] (envelope_is "lyft@shelvacu.com")}
      ${pure_flags [ "coursera" "D" ] (from_matches "*.*.coursera.org")}
      ${pure_flags [ "taskrabbit" "D" ] (envelope_is "taskrabbit@shelvacu.com")}
      ${pure_flags [ "subscribestar_code" "A" ] (allof [
        (envelope_is "subscribestar@shelvacu.com")
        (subject_is "Your authentication code")
      ])}
      ${pure_flags "itch-io" (from_is "postmaster@itch.io")}
      ${pure_flags
        [ "itch-io-update" "B.subscriptions" "not-spamish" ]
        [
          (has_flag "itch-io")
          (subject_matches "[itch.io] * update *")
        ]
      }
      ${pure_flags
        [ "lowering-the-bar" "B.subscriptions" "not-spamish" ]
        [
          (envelope_is "ltb@shelvacu.com")
        ]
      }
      ${pure_flags [ "hotels-com" "D" ] (from_matches [
        "hotels.com"
        "*.hotels.com"
      ])}
      ${pure_flags [ "dominos-rewards" "C" ] (from_is [ "rewards@e-rewards.dominos.com" ])}

      ${pure_flags
        [ "spamish-by-headers" "C" ]
        [
          (anyof [
            (header_is "Precedence" "bulk")
            (exists "List-Unsubscribe")
            (exists "List-Unsubscribe-Post")
          ])
          (not (has_flag "not-spamish"))
        ]
      }

      if hasflag "agora" {
        ${fileinto "M.agora"}
      } elsif hasflag "postgres-list" {
        ${fileinto "M.postgres"}
      } elsif hasflag "dmarc-reports" {
        ${fileinto "dmarc-reports"}
      } elsif hasflag "D" {
        ${fileinto "D"}
      } elsif hasflag "C" {
        ${fileinto "C"}
      } elsif hasflag "A" {
        ${fileinto "A"}
      } elsif hasflag "B.subscriptions" {
        ${fileinto "B.subscriptions"}
      } else {
        ${fileinto "B"}
      }
    }
    # disable any sieve scripts that might want to run after this one
    stop;
  '';
  pigeonhole_pkg = pkgs.dovecot_pigeonhole;
in
{
  imports = [
    # Allow running a sieve filter when a message gets moved to another folder in imap
    # see https://doc.dovecot.org/2.3/configuration_manual/sieve/plugins/imapsieve/
    {
      services.dovecot2 = {
        sieve.plugins = [ "sieve_imapsieve" ];
        mailPlugins.perProtocol.imap.enable = [ "imap_sieve" ];
      };
    }
  ];
  options.vacu.checkSieve = lib.mkOption {
    readOnly = true;
    default = pkgs.writeScriptBin "check-liam-sieve" ''
      set -xev
      ${lib.escapeShellArgs [
        (lib.getExe' pigeonhole_pkg "sieve-test")
        "-c"
        config.services.dovecot2.configFile
        "-C" # force compilation
        "-D" # enable sieve debugging
        "-f"
        "some-rando@example.com"
        "-a"
        "shelvacu@liam.dis8.net"
        config.services.dovecot2.sieve.scripts.before
        "/dev/null"
      ]}
    '';
    defaultText = "check-liam-sieve package";
  };
  options.vacu.liam-sieve-script = lib.mkOption {
    readOnly = true;
    default = pkgs.writeText "mainsieve" sieve_text;
    defaultText = "mainsieve text package";
  };
  config = {
    vacu.packages = [ pigeonhole_pkg ];
    services.dovecot2.sieve = {
      extensions = [
        "fileinto"
        "mailbox"
        "editheader"
        "vnd.dovecot.debug"
      ];
      scripts.before = config.vacu.liam-sieve-script;
    };
    services.dovecot2.imapsieve.mailbox = [
      {
        name = "*";
        causes = [
          "APPEND"
          "COPY"
          "FLAG"
        ];
        before = config.vacu.liam-sieve-script;
      }
    ];
    # services.dovecot2.mailboxes."magic-refilter".auto = "create";
  };
}
