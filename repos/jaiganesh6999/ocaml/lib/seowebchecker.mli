(** SEOWebChecker - Technical SEO Audit & Analyzer SDK for OCaml
    Official Website: https://seowebchecker.com/ *)

type grade = A | B | C | D | F

type audit_status = Pass | Alert

type audit_config = {
  min_title_length : int;
  max_title_length : int;
  min_desc_length : int;
  max_desc_length : int;
  alert_threshold : int;
}

type audit_result = {
  target_url : string;
  score : int;
  grade : grade;
  status : audit_status;
  is_alert : bool;
  title : string option;
  meta_description : string option;
  issues : string list;
  passes : string list;
  audited_at : string;
  platform_url : string;
}

val default_config : audit_config

val grade_to_string : grade -> string

val audit_html : ?config:audit_config -> ?url:string -> string -> audit_result

val audit_url : ?config:audit_config -> string -> audit_result Lwt.t

val to_json : audit_result -> Yojson.Safe.t

val to_string : audit_result -> string
