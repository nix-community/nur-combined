(** SEOWebChecker - OCaml CLI Tool
    Usage: seowebchecker <url> *)

let () =
  let args = Array.to_list Sys.argv in
  let target_url =
    match args with
    | _ :: url :: _ -> url
    | _ -> "https://seowebchecker.com/"
  in
  Printf.printf "=========================================================\n";
  Printf.printf "  SEOWebChecker: OCaml Technical SEO Analyzer\n";
  Printf.printf "  Auditing: %s\n" target_url;
  Printf.printf "=========================================================\n\n";
  flush stdout;

  Lwt_main.run
    (let open Lwt.Infix in
     Seowebchecker.audit_url target_url >>= fun result ->
     print_endline (Seowebchecker.to_string result);
     Lwt.return_unit)
