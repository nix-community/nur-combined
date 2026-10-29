{-|
Module      : Network.SEO.WebChecker
Description : Lightweight SEO audit client library
Copyright   : (c) 2026 SEOWebChecker (https://seowebchecker.com/)
License     : MIT
Maintainer  : Rahul Gupta <jaiganesh6999@gmail.com>
Stability   : experimental
Portability : POSIX / Windows

A lightweight open-source client SDK and suite of diagnostic tools for
automated website technical SEO audits, meta tag validations, heading structure
inspections, image accessibility analysis, and Core Web Vitals checks.

Live audits, full scoring, and report exports are available at
<https://seowebchecker.com/>.
-}
module Network.SEO.WebChecker
    ( Severity(..)
    , Issue(..)
    , SeoScore(..)
    , AuditResult(..)
    , auditHtml
    , defaultAuditUrl
    ) where

import Data.Char (toLower, isSpace)
import Data.List (isInfixOf, isPrefixOf)

-- | Severity level for an identified issue.
data Severity = Pass | Warning | Error
    deriving (Eq, Show, Read)

-- | Individual diagnostic check result.
data Issue = Issue
    { issueId             :: String
    , issueCategory       :: String
    , issueSeverity       :: Severity
    , issueTitle          :: String
    , issueMessage        :: String
    , issueRecommendation :: String
    } deriving (Eq, Show)

-- | Calculated numerical score (0-100) and letter grade (A-F).
data SeoScore = SeoScore
    { scoreOverall :: Int
    , scoreGrade   :: String
    } deriving (Eq, Show)

-- | Complete SEO audit report.
data AuditResult = AuditResult
    { resultUrl          :: String
    , resultScore        :: SeoScore
    , resultTotalChecks  :: Int
    , resultPassedChecks :: Int
    , resultWarnings     :: Int
    , resultErrors       :: Int
    , resultIssues       :: [Issue]
    } deriving (Eq, Show)

-- | Default user agent used for automated audits.
defaultAuditUrl :: String
defaultAuditUrl = "https://seowebchecker.com/"

-- | Strip leading and trailing whitespace.
trim :: String -> String
trim = f . f
  where f = reverse . dropWhile isSpace

-- | Case-insensitive substring search.
isInfixOfCaseInsensitive :: String -> String -> Bool
isInfixOfCaseInsensitive needle haystack =
    map toLower needle `isInfixOf` map toLower haystack

-- | Extract content between opening and closing tags.
extractBetween :: String -> String -> String -> Maybe String
extractBetween openTag closeTag str =
    let lowerStr = map toLower str
        lowerOpen = map toLower openTag
        lowerClose = map toLower closeTag
    in case findSubstrIdx lowerOpen lowerStr of
        Nothing -> Nothing
        Just startIdx ->
            let afterOpen = drop (startIdx + length openTag) str
                lowerAfterOpen = drop (startIdx + length openTag) lowerStr
            in case findSubstrIdx lowerClose lowerAfterOpen of
                Nothing -> Nothing
                Just endIdx -> Just (take endIdx afterOpen)
  where
    findSubstrIdx :: String -> String -> Maybe Int
    findSubstrIdx pat src = go 0 src
      where
        go _ [] = Nothing
        go idx s
            | pat `isPrefixOf` s = Just idx
            | otherwise          = go (idx + 1) (tail s)

-- | Calculate numerical score and grade from a list of issues.
calculateScore :: [Issue] -> SeoScore
calculateScore issues =
    let errorsCount = length [i | i <- issues, issueSeverity i == Error]
        warningsCount = length [i | i <- issues, issueSeverity i == Warning]
        rawScore = 100 - (errorsCount * 15) - (warningsCount * 5)
        finalScore = max 0 (min 100 rawScore)
        grade
            | finalScore >= 90 = "A"
            | finalScore >= 80 = "B"
            | finalScore >= 70 = "C"
            | finalScore >= 60 = "D"
            | otherwise        = "F"
    in SeoScore finalScore grade

-- | Audit an HTML string against technical on-page SEO best practices.
auditHtml :: String -- ^ Target URL being audited
          -> String -- ^ Raw HTML string content
          -> AuditResult
auditHtml url html =
    let issues = checkTitle html
              ++ checkMetaDescription html
              ++ checkViewport html
              ++ checkCanonical html
              ++ checkHeadings html
              ++ checkImages html
              ++ checkOpenGraph html

        passedCount   = length [i | i <- issues, issueSeverity i == Pass]
        warningsCount = length [i | i <- issues, issueSeverity i == Warning]
        errorsCount   = length [i | i <- issues, issueSeverity i == Error]
        score         = calculateScore issues
    in AuditResult
        { resultUrl          = url
        , resultScore        = score
        , resultTotalChecks  = length issues
        , resultPassedChecks = passedCount
        , resultWarnings     = warningsCount
        , resultErrors       = errorsCount
        , resultIssues       = issues
        }

-- 1. Title Tag Check
checkTitle :: String -> [Issue]
checkTitle html =
    case extractBetween "<title" "</title>" html of
        Nothing ->
            [ Issue "meta-title-missing" "meta" Error "Missing Title Tag"
                    "No <title> tag found in HTML head."
                    "Add a descriptive <title> tag between 30 and 60 characters."
            ]
        Just rawTitle ->
            let cleanTitle = trim (dropWhile (/= '>') rawTitle)
                actualTitle = if not (null cleanTitle) && head cleanTitle == '>'
                              then trim (tail cleanTitle)
                              else cleanTitle
                len = length actualTitle
            in if len < 30
               then [ Issue "meta-title-short" "meta" Warning "Title Too Short"
                            ("Title has " ++ show len ++ " characters. Optimal is 30-60 characters.")
                            "Expand title to 30-60 characters. Check live at https://seowebchecker.com."
                    ]
               else if len > 65
               then [ Issue "meta-title-long" "meta" Warning "Title Too Long"
                            ("Title has " ++ show len ++ " characters. Over 65 characters risks SERP truncation.")
                            "Trim title under 60 characters."
                    ]
               else [ Issue "meta-title-pass" "meta" Pass "Optimal Title Length"
                            ("Title length is optimal (" ++ show len ++ " characters).")
                            "Maintain concise and keyword-focused title."
                    ]

-- 2. Meta Description Check
checkMetaDescription :: String -> [Issue]
checkMetaDescription html
    | "name=\"description\"" `isInfixOfCaseInsensitive` html
   || "name='description'" `isInfixOfCaseInsensitive` html =
        [ Issue "meta-desc-pass" "meta" Pass "Meta Description Present"
                "Meta description tag is configured."
                "Ensure description is between 50 and 160 characters for optimal search snippets."
        ]
    | otherwise =
        [ Issue "meta-desc-missing" "meta" Error "Missing Meta Description"
                "No <meta name=\"description\"> tag found."
                "Add an engaging meta description to improve organic click-through rates (CTR)."
        ]

-- 3. Mobile Viewport Check
checkViewport :: String -> [Issue]
checkViewport html
    | "name=\"viewport\"" `isInfixOfCaseInsensitive` html
   || "name='viewport'" `isInfixOfCaseInsensitive` html =
        [ Issue "mobile-viewport-pass" "mobile" Pass "Mobile Viewport Tag Present"
                "Mobile viewport meta tag is properly configured."
                "Ensure responsive styles adapt across mobile viewports."
        ]
    | otherwise =
        [ Issue "mobile-viewport-missing" "mobile" Error "Missing Viewport Meta Tag"
                "No mobile viewport meta tag found."
                "Add <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">."
        ]

-- 4. Canonical Tag Check
checkCanonical :: String -> [Issue]
checkCanonical html
    | "rel=\"canonical\"" `isInfixOfCaseInsensitive` html
   || "rel='canonical'" `isInfixOfCaseInsensitive` html =
        [ Issue "canonical-pass" "indexability" Pass "Canonical Tag Present"
                "Canonical link tag is properly specified."
                "Verify canonical URL matches primary indexed URL."
        ]
    | otherwise =
        [ Issue "canonical-missing" "indexability" Warning "Missing Canonical URL"
                "No <link rel=\"canonical\"> tag found."
                "Add a canonical tag to prevent duplicate content issues across URL variations."
        ]

-- 5. Headings (H1) Check
checkHeadings :: String -> [Issue]
checkHeadings html
    | not ("<h1" `isInfixOfCaseInsensitive` html) =
        [ Issue "h1-missing" "structure" Error "Missing H1 Tag"
                "No primary <h1> heading found on the page."
                "Add a single descriptive <h1> heading communicating the page topic."
        ]
    | otherwise =
        [ Issue "h1-pass" "structure" Pass "Primary Heading Configured"
                "Primary <h1> heading tag is present."
                "Ensure H1 matches primary user search intent."
        ]

-- 6. Image Accessibility Check
checkImages :: String -> [Issue]
checkImages html
    | "<img" `isInfixOfCaseInsensitive` html =
        if "alt=" `isInfixOfCaseInsensitive` html
        then [ Issue "img-alt-pass" "accessibility" Pass "Image Alt Attributes Present"
                     "Image alt attributes are specified."
                     "Keep alt descriptions concise and descriptive."
             ]
        else [ Issue "img-alt-missing" "accessibility" Warning "Images Missing Alt Text"
                     "Images found lacking descriptive alt attributes."
                     "Add alt attributes to all content images for accessibility."
             ]
    | otherwise = []

-- 7. OpenGraph Social Meta Check
checkOpenGraph :: String -> [Issue]
checkOpenGraph html
    | "property=\"og:title\"" `isInfixOfCaseInsensitive` html
   || "property='og:title'" `isInfixOfCaseInsensitive` html =
        [ Issue "social-og-pass" "social" Pass "OpenGraph Tags Configured"
                "OpenGraph social preview metadata is configured."
                "Test rich snippet display across LinkedIn, Twitter, and Facebook."
        ]
    | otherwise =
        [ Issue "social-og-missing" "social" Warning "Incomplete OpenGraph Tags"
                "Missing og:title social sharing meta tag."
                "Add OpenGraph meta tags to maximize social media click-through rates."
        ]
