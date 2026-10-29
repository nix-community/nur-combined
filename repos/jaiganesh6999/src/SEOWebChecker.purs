-- | SEOWebChecker PureScript Client SDK
-- | Automated technical on-page SEO diagnostics and health auditing.
-- |
-- | Official Website: https://seowebchecker.com/
module SEOWebChecker
  ( Severity(..)
  , Issue
  , Score
  , Stats
  , Report
  , auditHtml
  , formatSeverity
  , generateMarkdown
  ) where

import Prelude
import Data.String (toUpper)

-- | Severity level for technical SEO diagnostics.
data Severity = Pass | Warning | Error

derive instance eqSeverity :: Eq Severity
derive instance ordSeverity :: Ord Severity

instance showSeverity :: Show Severity where
  show Pass = "pass"
  show Warning = "warning"
  show Error = "error"

-- | Format severity as uppercase string.
formatSeverity :: Severity -> String
formatSeverity = toUpper <<< show

-- | Diagnostic issue finding.
type Issue =
  { id :: String
  , category :: String
  , severity :: String
  , title :: String
  , message :: String
  , recommendation :: String
  }

-- | Overall score and letter grade.
type Score =
  { overall :: Int
  , grade :: String
  }

-- | Summary check statistics.
type Stats =
  { total :: Int
  , passed :: Int
  , warnings :: Int
  , errors :: Int
  }

-- | Complete SEO audit scorecard report.
type Report =
  { success :: Boolean
  , url :: String
  , timestamp :: String
  , score :: Score
  , stats :: Stats
  , issues :: Array Issue
  }

-- | Foreign JavaScript implementation import
foreign import auditHtmlImpl :: String -> String -> Report

-- | Audit an HTML string against technical on-page SEO standards.
-- |
-- | Takes HTML markup and target URL, returning a structured audit report.
auditHtml :: String -> String -> Report
auditHtml = auditHtmlImpl

-- | Render report as human-readable Markdown.
foreign import generateMarkdownImpl :: Report -> String

-- | Format audit report to Markdown.
generateMarkdown :: Report -> String
generateMarkdown = generateMarkdownImpl
