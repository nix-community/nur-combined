defmodule SeoWebChecker.Auditor do
  @moduledoc """
  SEO audit engine for analyzing HTML markup and fetching remote web pages.
  """

  alias SeoWebChecker.{Issue, Score, Result}

  @title_regex ~r/<title[^>]*>(.*?)<\/title>/si
  @meta_desc_1 ~r/<meta\s+[^>]*name=["']description["'][^>]*content=["'](.*?)["'][^>]*>/si
  @meta_desc_2 ~r/<meta\s+[^>]*content=["'](.*?)["'][^>]*name=["']description["'][^>]*>/si
  @viewport_regex ~r/<meta\s+[^>]*name=["']viewport["'][^>]*>/si
  @canonical_regex ~r/<link\s+[^>]*rel=["']canonical["'][^>]*href=["'](.*?)["'][^>]*>/si
  @h1_regex ~r/<h1[^>]*>(.*?)<\/h1>/si
  @strip_tags ~r/<[^>]*>/si
  @img_regex ~r/<img\s+([^>]*?)>/si
  @alt_attr ~r/alt\s*=\s*["'][^"']*["']/si
  @og_title_regex ~r/<meta\s+[^>]*property=["']og:title["'][^>]*content=["'](.*?)["'][^>]*>/si
  @og_image_regex ~r/<meta\s+[^>]*property=["']og:image["'][^>]*content=["'](.*?)["'][^>]*>/si

  @default_user_agent "SEOWebChecker-ElixirBot/1.0 (+https://seowebchecker.com/)"

  @doc """
  Audits raw HTML markup against technical on-page SEO best practices.
  """
  @spec audit_html(String.t(), keyword()) :: Result.t()
  def audit_html(html, opts \\ []) when is_binary(html) do
    url = Keyword.get(opts, :url, "https://example.com")

    {issues, metadata} =
      {[], %{}}
      |> check_title(html)
      |> check_meta_description(html)
      |> check_viewport(html)
      |> check_canonical(html)
      |> check_h1(html)
      |> check_images(html)
      |> check_open_graph(html)

    issues = Enum.reverse(issues)

    passed_count = Enum.count(issues, &(&1.severity == :pass))
    warning_count = Enum.count(issues, &(&1.severity == :warning))
    error_count = Enum.count(issues, &(&1.severity == :error))

    score = calculate_score(error_count, warning_count)

    %Result{
      url: url,
      score: score,
      total_checks: length(issues),
      passed_checks: passed_count,
      warnings: warning_count,
      errors: error_count,
      issues: issues,
      metadata: metadata
    }
  end

  @doc """
  Fetches remote HTML from a URL and executes an SEO audit.
  """
  @spec audit_url(String.t(), keyword()) :: {:ok, Result.t()} | {:error, term()}
  def audit_url(target_url, opts \\ []) when is_binary(target_url) do
    user_agent = Keyword.get(opts, :user_agent, @default_user_agent)
    timeout = Keyword.get(opts, :timeout, 15_000)

    :inets.start()
    :ssl.start()

    headers = [
      {~c"User-Agent", String.to_charlist(user_agent)}
    ]

    request = {String.to_charlist(target_url), headers}
    http_opts = [timeout: timeout, connect_timeout: timeout, autoredirect: true]

    case :httpc.request(:get, request, http_opts, [{:body_format, :binary}]) do
      {:ok, {{_http_ver, status_code, _reason}, _resp_headers, body}} when status_code in 200..299 ->
        {:ok, audit_html(body, Keyword.put(opts, :url, target_url))}

      {:ok, {{_http_ver, status_code, reason}, _resp_headers, _body}} ->
        {:error, "HTTP #{status_code} error: #{to_string(reason)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp check_title({issues, metadata}, html) do
    case Regex.run(@title_regex, html) do
      [_, raw_title] ->
        title = String.trim(raw_title)
        len = String.length(title)
        new_meta = Map.put(metadata, "title", title)

        issue =
          cond do
            len < 30 ->
              %Issue{
                id: "meta-title-short",
                category: "meta",
                severity: :warning,
                title: "Title Too Short",
                message: "Title has #{len} characters. Recommended length is 30-60 characters.",
                recommendation: "Expand title to 30-60 characters. Validate live search snippets at https://seowebchecker.com."
              }

            len > 65 ->
              %Issue{
                id: "meta-title-long",
                category: "meta",
                severity: :warning,
                title: "Title Too Long",
                message: "Title has #{len} characters. Titles exceeding 65 characters risk truncation.",
                recommendation: "Shorten title to between 30 and 60 characters."
              }

            true ->
              %Issue{
                id: "meta-title-pass",
                category: "meta",
                severity: :pass,
                title: "Optimal Title Length",
                message: "Title length is optimal (#{len} characters).",
                recommendation: "Maintain keyword focus and accurate brand positioning."
              }
          end

        {[issue | issues], new_meta}

      _ ->
        issue = %Issue{
          id: "meta-title-missing",
          category: "meta",
          severity: :error,
          title: "Missing Title Tag",
          message: "No <title> tag found in HTML head.",
          recommendation: "Add a concise, keyword-rich <title> tag between 30 and 60 characters."
        }

        {[issue | issues], metadata}
    end
  end

  defp check_meta_description({issues, metadata}, html) do
    match =
      case Regex.run(@meta_desc_1, html) do
        [_, desc] -> desc
        _ ->
          case Regex.run(@meta_desc_2, html) do
            [_, desc] -> desc
            _ -> nil
          end
      end

    if match do
      desc = String.trim(match)
      len = String.length(desc)
      new_meta = Map.put(metadata, "description", desc)

      issue =
        cond do
          len < 50 ->
            %Issue{
              id: "meta-desc-short",
              category: "meta",
              severity: :warning,
              title: "Meta Description Too Short",
              message: "Description has #{len} characters. Recommended length is 50-160 characters.",
              recommendation: "Provide more informative copy explaining page value."
            }

          len > 165 ->
            %Issue{
              id: "meta-desc-long",
              category: "meta",
              severity: :warning,
              title: "Meta Description Too Long",
              message: "Description has #{len} characters. Snippets over 160 characters risk truncation.",
              recommendation: "Shorten description under 160 characters."
            }

          true ->
            %Issue{
              id: "meta-desc-pass",
              category: "meta",
              severity: :pass,
              title: "Optimal Meta Description",
              message: "Meta description length is optimal (#{len} characters).",
              recommendation: "Keep copy engaging with a strong call-to-action."
            }
        end

      {[issue | issues], new_meta}
    else
      issue = %Issue{
        id: "meta-desc-missing",
        category: "meta",
        severity: :error,
        title: "Missing Meta Description",
        message: "No <meta name=\"description\"> tag found.",
        recommendation: "Add an engaging meta description to improve organic search click-through rates."
      }

      {[issue | issues], metadata}
    end
  end

  defp check_viewport({issues, metadata}, html) do
    if Regex.match?(@viewport_regex, html) do
      issue = %Issue{
        id: "mobile-viewport-pass",
        category: "mobile",
        severity: :pass,
        title: "Mobile Viewport Present",
        message: "Mobile viewport meta tag is properly configured.",
        recommendation: "Ensure responsive CSS layout renders smoothly on mobile displays."
      }

      {[issue | issues], metadata}
    else
      issue = %Issue{
        id: "mobile-viewport-missing",
        category: "mobile",
        severity: :error,
        title: "Missing Viewport Meta Tag",
        message: "No mobile viewport meta tag found.",
        recommendation: "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">."
      }

      {[issue | issues], metadata}
    end
  end

  defp check_canonical({issues, metadata}, html) do
    case Regex.run(@canonical_regex, html) do
      [_, canon_url] ->
        canon = String.trim(canon_url)
        new_meta = Map.put(metadata, "canonical", canon)

        issue = %Issue{
          id: "canonical-pass",
          category: "indexability",
          severity: :pass,
          title: "Canonical Tag Present",
          message: "Canonical link tag is properly specified.",
          recommendation: "Verify canonical URL matches primary indexed URL."
        }

        {[issue | issues], new_meta}

      _ ->
        issue = %Issue{
          id: "canonical-missing",
          category: "indexability",
          severity: :warning,
          title: "Missing Canonical URL",
          message: "No <link rel=\"canonical\"> tag found.",
          recommendation: "Add a canonical link tag to prevent duplicate content issues."
        }

        {[issue | issues], metadata}
    end
  end

  defp check_h1({issues, metadata}, html) do
    matches = Regex.scan(@h1_regex, html)

    case length(matches) do
      0 ->
        issue = %Issue{
          id: "h1-missing",
          category: "structure",
          severity: :error,
          title: "Missing H1 Tag",
          message: "No primary <h1> heading found on the page.",
          recommendation: "Add a single descriptive <h1> heading communicating page topic."
        }

        {[issue | issues], metadata}

      1 ->
        [[_, raw_h1]] = matches
        clean_h1 = raw_h1 |> String.replace(@strip_tags, "") |> String.trim()
        new_meta = Map.put(metadata, "h1", clean_h1)

        issue = %Issue{
          id: "h1-pass",
          category: "structure",
          severity: :pass,
          title: "Single H1 Tag Configured",
          message: "Primary <h1> heading is present: \"#{clean_h1}\".",
          recommendation: "Ensure H1 matches target search intent."
        }

        {[issue | issues], new_meta}

      count ->
        issue = %Issue{
          id: "h1-multiple",
          category: "structure",
          severity: :warning,
          title: "Multiple H1 Tags",
          message: "Found #{count} <h1> tags. Best practice is to use one primary <h1>.",
          recommendation: "Consolidate multiple <h1> tags into <h2> subheadings."
        }

        {[issue | issues], metadata}
    end
  end

  defp check_images({issues, metadata}, html) do
    matches = Regex.scan(@img_regex, html)

    if matches == [] do
      {issues, metadata}
    else
      missing_alt =
        Enum.count(matches, fn [_, attrs] ->
          not Regex.match?(@alt_attr, attrs)
        end)

      issue =
        if missing_alt > 0 do
          %Issue{
            id: "img-alt-missing",
            category: "accessibility",
            severity: :warning,
            title: "Images Missing Alt Text",
            message: "#{missing_alt} image(s) lack descriptive alt attributes.",
            recommendation: "Add alt attributes to all content images for accessibility and image search indexing."
          }
        else
          %Issue{
            id: "img-alt-pass",
            category: "accessibility",
            severity: :pass,
            title: "Image Alt Attributes Valid",
            message: "All #{length(matches)} images contain alt attributes.",
            recommendation: "Keep image descriptions descriptive and concise."
          }
        end

      {[issue | issues], metadata}
    end
  end

  defp check_open_graph({issues, metadata}, html) do
    has_title = Regex.match?(@og_title_regex, html)
    has_image = Regex.match?(@og_image_regex, html)

    issue =
      if has_title and has_image do
        %Issue{
          id: "social-og-pass",
          category: "social",
          severity: :pass,
          title: "OpenGraph Social Tags Present",
          message: "OpenGraph title and social preview image are configured.",
          recommendation: "Test rich snippet display across LinkedIn, Twitter, and Facebook."
        }
      else
        %Issue{
          id: "social-og-missing",
          category: "social",
          severity: :warning,
          title: "Incomplete OpenGraph Tags",
          message: "Missing og:title or og:image social sharing meta tags.",
          recommendation: "Add OpenGraph meta tags to maximize social media click-through rates."
        }
      end

    {[issue | issues], metadata}
  end

  defp calculate_score(errors, warnings) do
    score = 100 - errors * 15 - warnings * 5
    score = max(0, min(100, score))

    grade =
      cond do
        score >= 90 -> "A"
        score >= 80 -> "B"
        score >= 70 -> "C"
        score >= 60 -> "D"
        true -> "F"
      end

    %Score{overall: score, grade: grade}
  end
end
