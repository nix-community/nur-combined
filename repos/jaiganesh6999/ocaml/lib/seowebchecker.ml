(** SEOWebChecker - Technical SEO Audit & Analyzer SDK for OCaml
    Official Website: https://seowebchecker.com/ *)

open Lwt.Infix

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

let default_config = {
  min_title_length = 30;
  max_title_length = 60;
  min_desc_length = 70;
  max_desc_length = 160;
  alert_threshold = 85;
}

let grade_to_string = function
  | A -> "A"
  | B -> "B"
  | C -> "C"
  | D -> "D"
  | F -> "F"

let score_to_grade score =
  if score >= 90 then A
  else if score >= 80 then B
  else if score >= 70 then C
  else if score >= 60 then D
  else F

let audit_html ?(config = default_config) ?(url = "https://seowebchecker.com/") html =
  let soup = Soup.parse html in
  let issues = ref [] in
  let passes = ref [] in
  let score = ref 100 in

  (* 1. Title Tag Check *)
  let title_opt =
    match Soup.select_one "title" soup with
    | Some node ->
        let t = String.trim (Soup.texts node |> String.concat " ") in
        if String.length t > 0 then Some t else None
    | None -> None
  in
  (match title_opt with
  | None ->
      issues := "Missing <title> tag (-20 pts)" :: !issues;
      score := !score - 20
  | Some t ->
      let len = String.length t in
      if len < config.min_title_length then (
        issues := Printf.sprintf "Title tag too short (%d chars, recommended %d-%d) (-5 pts)"
                    len config.min_title_length config.max_title_length :: !issues;
        score := !score - 5
      ) else if len > config.max_title_length then (
        issues := Printf.sprintf "Title tag may truncate (%d chars, recommended %d-%d) (-5 pts)"
                    len config.min_title_length config.max_title_length :: !issues;
        score := !score - 5
      ) else
        passes := Printf.sprintf "Title tag optimal (%d chars)" len :: !passes);

  (* 2. Meta Description Check *)
  let desc_opt =
    match Soup.select_one "meta[name='description']" soup with
    | Some node -> Soup.attribute "content" node
    | None -> (
        match Soup.select_one "meta[name='Description']" soup with
        | Some node -> Soup.attribute "content" node
        | None -> None)
  in
  (match desc_opt with
  | None ->
      issues := "Missing meta description tag (-15 pts)" :: !issues;
      score := !score - 15
  | Some d ->
      let len = String.length (String.trim d) in
      if len < config.min_desc_length then (
        issues := Printf.sprintf "Meta description too short (%d chars, recommended %d-%d) (-5 pts)"
                    len config.min_desc_length config.max_desc_length :: !issues;
        score := !score - 5
      ) else if len > config.max_desc_length then (
        issues := Printf.sprintf "Meta description exceeds recommended length (%d chars) (-5 pts)" len :: !issues;
        score := !score - 5
      ) else
        passes := Printf.sprintf "Meta description optimal (%d chars)" len :: !passes);

  (* 3. Heading Hierarchy (H1 Check) *)
  let h1_nodes = Soup.select "h1" soup |> Soup.to_list in
  let h1_count = List.length h1_nodes in
  if h1_count = 0 then (
    issues := "Missing <h1> tag (-15 pts)" :: !issues;
    score := !score - 15
  ) else if h1_count > 1 then (
    issues := Printf.sprintf "Multiple <h1> tags detected (%d found) (-10 pts)" h1_count :: !issues;
    score := !score - 10
  ) else
    passes := "Exactly one <h1> heading present" :: !passes;

  (* 4. Mobile Viewport Check *)
  (match Soup.select_one "meta[name='viewport']" soup with
  | None ->
      issues := "Missing mobile viewport meta tag (-15 pts)" :: !issues;
      score := !score - 15
  | Some _ ->
      passes := "Mobile viewport meta tag configured" :: !passes);

  (* 5. Canonical Link Check *)
  (match Soup.select_one "link[rel='canonical']" soup with
  | None ->
      issues := "Missing canonical link tag (-10 pts)" :: !issues;
      score := !score - 10
  | Some _ ->
      passes := "Canonical link tag present" :: !passes);

  (* 6. Image Accessibility (Alt Text) *)
  let img_nodes = Soup.select "img" soup |> Soup.to_list in
  let missing_alt =
    List.fold_left
      (fun acc node ->
        match Soup.attribute "alt" node with
        | Some _ -> acc
        | None -> acc + 1)
      0 img_nodes
  in
  if missing_alt > 0 then (
    issues := Printf.sprintf "%d image(s) missing alt attribute (-10 pts)" missing_alt :: !issues;
    score := !score - 10
  ) else if List.length img_nodes > 0 then
    passes := Printf.sprintf "All %d images include alt attributes" (List.length img_nodes) :: !passes;

  (* 7. OpenGraph Social Tags *)
  let has_og_title = Soup.select_one "meta[property='og:title']" soup <> None in
  let has_og_image = Soup.select_one "meta[property='og:image']" soup <> None in
  if not (has_og_title && has_og_image) then (
    issues := "Incomplete OpenGraph tags (og:title / og:image missing) (-5 pts)" :: !issues;
    score := !score - 5
  ) else
    passes := "OpenGraph social tags present" :: !passes;

  let final_score = max 0 !score in
  let g = score_to_grade final_score in
  let is_alt = final_score < config.alert_threshold in
  let st = if is_alt then Alert else Pass in

  {
    target_url = url;
    score = final_score;
    grade = g;
    status = st;
    is_alert = is_alt;
    title = title_opt;
    meta_description = desc_opt;
    issues = List.rev !issues;
    passes = List.rev !passes;
    audited_at = string_of_float (Unix.gettimeofday ());
    platform_url = "https://seowebchecker.com/";
  }

let audit_url ?(config = default_config) url_str =
  let uri = Uri.of_string url_str in
  let headers =
    Cohttp.Header.init_with "User-Agent"
      "Mozilla/5.0 (compatible; SEOWebChecker-OCaml-Bot/1.0; +https://seowebchecker.com/)"
  in
  Cohttp_lwt_unix.Client.get ~headers uri >>= fun (_resp, body) ->
  Cohttp_lwt.Body.to_string body >>= fun html ->
  Lwt.return (audit_html ~config ~url:url_str html)

let to_json (r : audit_result) : Yojson.Safe.t =
  `Assoc
    [
      ("target_url", `String r.target_url);
      ("score", `Int r.score);
      ("grade", `String (grade_to_string r.grade));
      ("status", `String (if r.status = Pass then "PASS" else "ALERT"));
      ("is_alert", `Bool r.is_alert);
      ("title", match r.title with Some t -> `String t | None -> `Null);
      ("meta_description", match r.meta_description with Some d -> `String d | None -> `Null);
      ("issues", `List (List.map (fun s -> `String s) r.issues));
      ("passes", `List (List.map (fun s -> `String s) r.passes));
      ("audited_at", `String r.audited_at);
      ("platform_url", `String r.platform_url);
    ]

let to_string (r : audit_result) =
  Yojson.Safe.pretty_to_string (to_json r)
