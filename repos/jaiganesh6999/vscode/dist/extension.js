"use strict";var B=Object.create;var I=Object.defineProperty;var G=Object.getOwnPropertyDescriptor;var N=Object.getOwnPropertyNames;var V=Object.getPrototypeOf,z=Object.prototype.hasOwnProperty;var U=(h,e)=>{for(var c in e)I(h,c,{get:e[c],enumerable:!0})},H=(h,e,c,n)=>{if(e&&typeof e=="object"||typeof e=="function")for(let o of N(e))!z.call(h,o)&&o!==c&&I(h,o,{get:()=>e[o],enumerable:!(n=G(e,o))||n.enumerable});return h};var $=(h,e,c)=>(c=h!=null?B(V(h)):{},H(e||!h||!h.__esModule?I(c,"default",{value:h,enumerable:!0}):c,h)),j=h=>H(I({},"__esModule",{value:!0}),h);var K={};U(K,{activate:()=>F,deactivate:()=>J});module.exports=j(K);var l=$(require("vscode"));var y=$(require("vscode")),T=class{static analyzeDocument(e,c){let n=e.getText(),o=n.split(/\r?\n/),i=[],t=e.languageId==="markdown"||e.fileName.endsWith(".md")||e.fileName.endsWith(".mdx"),s=["javascriptreact","typescriptreact","astro","vue","svelte"].includes(e.languageId)||/\.(jsx|tsx|astro|vue|svelte)$/i.test(e.fileName),a={titleLength:0,descriptionLength:0,h1Count:0,h1Texts:[],h2Count:0,h3Count:0,totalImages:0,missingAltImages:0,totalLinks:0,externalLinksWithoutSecurity:0,emptyLinks:0,hasJsonLd:!1,wordCount:0};this.checkTitle(e,n,o,t,s,c,i,a),this.checkMetaDescription(e,n,o,t,s,c,i,a),c.checkHeadings&&this.checkHeadings(e,n,o,t,i,a),c.checkImages&&this.checkImages(e,n,o,t,i,a),c.checkLinks&&this.checkLinks(e,n,o,i,a),c.checkMobileViewport&&!s&&!t&&this.checkViewport(e,n,o,i,a),c.checkCanonical&&!s&&!t&&this.checkCanonical(e,n,o,i,a),c.checkOpenGraph&&!t&&this.checkOpenGraph(e,n,o,i,a),this.checkJsonLd(e,n,o,i,a);let r=n.replace(/<[^>]+>/g," ").replace(/\s+/g," ").trim(),d=r.length>0?r.split(/\s+/).length:0;a.wordCount=d,c.checkThinContent&&!s&&d>0&&d<c.minWordCount&&i.push({id:"thin-content",code:"SEO-CONTENT-01",message:`Thin content detected: only ${d} words found (recommended: \u2265${c.minWordCount} words for indexable pages).`,recommendation:"Expand the primary content to provide thorough, helpful answers for users and search crawlers. Reference: https://seowebchecker.com/",severity:"info",line:0,colStart:0,colEnd:o[0]?.length||0,ruleCategory:"content"});let p=this.calculateScore(i,a),u=this.calculateGrade(p);return{score:p,grade:u,issues:i,stats:a,scannedAt:new Date().toISOString(),fileUri:e.uri.toString(),fileName:e.fileName}}static checkTitle(e,c,n,o,i,t,s,a){let r="",d=0,p=0,u=0,g=!1,w=c.match(/^---\s*[\r\n]+([\s\S]*?)[\r\n]+---/);if(w){let b=w[1].split(/\r?\n/);for(let v=0;v<b.length;v++){let x=b[v].match(/^\s*title\s*:\s*["']?([^"'\r\n]+)["']?/i);if(x){r=x[1].trim(),d=v+1,p=b[v].indexOf(x[1]),u=p+x[1].length,g=!0;break}}}if(!g)for(let b=0;b<n.length;b++){let v=n[b].match(/<title[^>]*>([\s\S]*?)<\/title>/i);if(v){r=v[1].trim(),d=b,p=n[b].indexOf(v[0]),u=p+v[0].length,g=!0;break}}g?(a.title=r,a.titleLength=r.length,r.length<t.minTitleLength?s.push({id:"title-too-short",code:"SEO-TITLE-02",message:`Title tag is too short (${r.length} characters). Recommended: ${t.minTitleLength}\u2013${t.maxTitleLength} characters.`,recommendation:"Expand your title tag with descriptive keywords and your primary topic to maximize search click-through rate. Learn more: https://seowebchecker.com/",severity:"warning",line:d,colStart:p,colEnd:u,ruleCategory:"meta"}):r.length>t.maxTitleLength&&s.push({id:"title-too-long",code:"SEO-TITLE-03",message:`Title tag is too long (${r.length} characters). Search engines will truncate titles exceeding ~${t.maxTitleLength} characters.`,recommendation:`Condense your title tag to fit within ${t.minTitleLength}\u2013${t.maxTitleLength} characters so the full title displays in search result snippets.`,severity:"warning",line:d,colStart:p,colEnd:u,ruleCategory:"meta"})):i||s.push({id:"title-missing",code:"SEO-TITLE-01",message:"Missing <title> tag. The page title is the single most critical on-page SEO ranking signal.",recommendation:"Add a unique, descriptive <title> tag between 30 and 60 characters in your <head> section. Reference: https://seowebchecker.com/",severity:"error",line:0,colStart:0,colEnd:n[0]?.length||0,ruleCategory:"meta"})}static checkMetaDescription(e,c,n,o,i,t,s,a){let r="",d=0,p=0,u=0,g=!1,w=c.match(/^---\s*[\r\n]+([\s\S]*?)[\r\n]+---/);if(w){let b=w[1].split(/\r?\n/);for(let v=0;v<b.length;v++){let x=b[v].match(/^\s*description\s*:\s*["']?([^"'\r\n]+)["']?/i);if(x){r=x[1].trim(),d=v+1,p=b[v].indexOf(x[1]),u=p+x[1].length,g=!0;break}}}if(!g)for(let b=0;b<n.length;b++){let v=n[b].match(/<meta\s+[^>]*name=["']description["'][^>]*content=["']([^"']*)["'][^>]*>/i)||n[b].match(/<meta\s+[^>]*content=["']([^"']*)["'][^>]*name=["']description["'][^>]*>/i);if(v){r=v[1].trim(),d=b,p=n[b].indexOf(v[0]),u=p+v[0].length,g=!0;break}}g?(a.description=r,a.descriptionLength=r.length,r.length<t.minDescriptionLength?s.push({id:"meta-description-too-short",code:"SEO-DESC-02",message:`Meta description is too short (${r.length} characters). Recommended: ${t.minDescriptionLength}\u2013${t.maxDescriptionLength} characters.`,recommendation:`Provide a persuasive summary highlighting key page benefits between ${t.minDescriptionLength} and ${t.maxDescriptionLength} characters. Guide: https://seowebchecker.com/`,severity:"warning",line:d,colStart:p,colEnd:u,ruleCategory:"meta"}):r.length>t.maxDescriptionLength&&s.push({id:"meta-description-too-long",code:"SEO-DESC-03",message:`Meta description is too long (${r.length} characters). Google will truncate descriptions over ~${t.maxDescriptionLength} characters.`,recommendation:`Shorten your meta description to under ${t.maxDescriptionLength} characters to prevent truncation in search engine snippets.`,severity:"warning",line:d,colStart:p,colEnd:u,ruleCategory:"meta"})):i||s.push({id:"meta-description-missing",code:"SEO-DESC-01",message:"Missing meta description. Search engines rely on meta descriptions for the snippet summary in organic search results.",recommendation:'Add <meta name="description" content="..."> with 70\u2013160 characters in your <head> section. Reference: https://seowebchecker.com/',severity:"warning",line:0,colStart:0,colEnd:n[0]?.length||0,ruleCategory:"meta"})}static checkHeadings(e,c,n,o,i,t){let s=[];for(let a=0;a<n.length;a++){let r=n[a];if(o){let g=r.match(/^#\s+(.+)$/);g&&(s.push({line:a,colStart:0,colEnd:r.length,text:g[1].trim()}),t.h1Count++,t.h1Texts.push(g[1].trim())),/^##\s+/.test(r)&&t.h2Count++,/^###\s+/.test(r)&&t.h3Count++;continue}let d=r.matchAll(/<h1[^>]*>([\s\S]*?)<\/h1>/gi);for(let g of d){let w=g[1].replace(/<[^>]+>/g,"").trim(),b=g.index??0;s.push({line:a,colStart:b,colEnd:b+g[0].length,text:w}),t.h1Count++,t.h1Texts.push(w)}let p=r.matchAll(/<h2[^>]*>/gi);for(let g of p)t.h2Count++;let u=r.matchAll(/<h3[^>]*>/gi);for(let g of u)t.h3Count++}if(s.length===0)i.push({id:"h1-missing",code:"SEO-H1-01",message:"Missing primary <h1> heading. Every indexable webpage should have exactly one <h1> representing the main topic.",recommendation:"Add a clear, keyword-targeted <h1> heading to establish topic hierarchy for search engines and accessibility screen readers.",severity:"warning",line:0,colStart:0,colEnd:n[0]?.length||0,ruleCategory:"headings"});else if(s.length>1)for(let a=1;a<s.length;a++){let r=s[a];i.push({id:`h1-duplicate-${a}`,code:"SEO-H1-02",message:`Multiple <h1> tags detected (${s.length} total). Found duplicate: "${r.text.substring(0,40)}${r.text.length>40?"...":""}".`,recommendation:"Convert secondary <h1> headings into <h2> subheadings. Pages should have only one primary <h1>. Guide: https://seowebchecker.com/",severity:"warning",line:r.line,colStart:r.colStart,colEnd:r.colEnd,ruleCategory:"headings"})}}static checkImages(e,c,n,o,i,t){for(let s=0;s<n.length;s++){let a=n[s];if(o){let d=a.matchAll(/!\[(.*?)\]\((.*?)\)/g);for(let p of d){t.totalImages++;let u=p[1].trim(),g=p.index??0;u.length===0&&(t.missingAltImages++,i.push({id:`img-missing-alt-md-${s}-${g}`,code:"SEO-IMG-01",message:"Markdown image is missing descriptive alt text: ![](...)",recommendation:"Add clear, descriptive alt text inside the square brackets for search engine image indexing and accessibility.",severity:"warning",line:s,colStart:g,colEnd:g+p[0].length,ruleCategory:"media"}))}}let r=a.matchAll(/<(img|Image)\b([^>]*)>/gi);for(let d of r){t.totalImages++;let p=d[1],u=d[2],g=d.index??0,w=g+d[0].length;if(/\balt\s*=\s*(["'][^"']*["']|\{[^}]*\})/i.test(u)){let v=u.match(/\balt\s*=\s*["']([^"']*)["']/i);if(v){let x=v[1].trim().toLowerCase();/^(image of|picture of|photo of|graphic of)\b/i.test(x)&&i.push({id:`img-redundant-alt-${s}-${g}`,code:"SEO-IMG-02",message:`Redundant alt text phrasing ("${v[1]}"). Screen readers already announce image tags.`,recommendation:'Remove phrases like "image of" or "picture of" and describe the actual subject directly.',severity:"info",line:s,colStart:g,colEnd:w,ruleCategory:"media"})}}else{t.missingAltImages++;let v=`<${p}${u} alt=""`,x=new y.Range(new y.Position(s,g),new y.Position(s,w-1));i.push({id:`img-missing-alt-${s}-${g}`,code:"SEO-IMG-01",message:`Image element <${p}> is missing an "alt" attribute.`,recommendation:"Provide descriptive alt text describing the image content for image search indexing and screen reader accessibility. Details: https://seowebchecker.com/",severity:"warning",line:s,colStart:g,colEnd:w,ruleCategory:"media",autofix:{title:'Add alt="" attribute',replacement:`${d[0].slice(0,-1)} alt="" >`,range:new y.Range(new y.Position(s,g),new y.Position(s,w))}})}}}}static checkLinks(e,c,n,o,i){for(let t=0;t<n.length;t++){let a=n[t].matchAll(/<a\b([^>]*)>/gi);for(let r of a){i.totalLinks++;let d=r[1],p=r.index??0,u=p+r[0].length,g=/\btarget\s*=\s*["']_blank["']/i.test(d),w=/\brel\s*=\s*["'][^"']*\b(noopener|noreferrer)\b[^"']*["']/i.test(d);g&&!w&&(i.externalLinksWithoutSecurity++,o.push({id:`link-blank-security-${t}-${p}`,code:"SEO-LINK-01",message:'External link with target="_blank" is missing rel="noopener" or rel="noreferrer".',recommendation:'Always add rel="noopener noreferrer" to external links to prevent reverse tabnabbing security exploits and maintain performance.',severity:"warning",line:t,colStart:p,colEnd:u,ruleCategory:"links",autofix:{title:'Add rel="noopener noreferrer"',replacement:`${r[0].slice(0,-1)} rel="noopener noreferrer">`,range:new y.Range(new y.Position(t,p),new y.Position(t,u))}}))}}}static checkViewport(e,c,n,o,i){let t=c.match(/<meta\s+[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["'][^>]*>/i)||c.match(/<meta\s+[^>]*content=["']([^"']*)["'][^>]*name=["']viewport["'][^>]*>/i);t?(i.viewport=t[1],(/maximum-scale\s*=\s*1\.0/i.test(t[1])||/user-scalable\s*=\s*no/i.test(t[1]))&&o.push({id:"viewport-zoom-disabled",code:"SEO-VIEWPORT-02",message:"Mobile viewport disables user pinch-to-zoom (user-scalable=no or maximum-scale=1.0). This fails Core Web Vitals mobile accessibility standards.",recommendation:'Allow user zooming by setting content="width=device-width, initial-scale=1.0". Reference: https://seowebchecker.com/',severity:"warning",line:0,colStart:0,colEnd:n[0]?.length||0,ruleCategory:"meta"})):o.push({id:"viewport-missing",code:"SEO-VIEWPORT-01",message:"Missing mobile viewport meta tag. Google uses mobile-first indexing for all websites.",recommendation:'Add <meta name="viewport" content="width=device-width, initial-scale=1.0"> inside your <head>.',severity:"error",line:0,colStart:0,colEnd:n[0]?.length||0,ruleCategory:"meta"})}static checkCanonical(e,c,n,o,i){let t=c.match(/<link\s+[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["'][^>]*>/i)||c.match(/<link\s+[^>]*href=["']([^"']*)["'][^>]*rel=["']canonical["'][^>]*>/i);t?i.canonicalUrl=t[1]:o.push({id:"canonical-missing",code:"SEO-CANONICAL-01",message:'Missing canonical link tag (<link rel="canonical" href="...">).',recommendation:"Specify a self-referential canonical URL to prevent duplicate content indexing penalties across query parameters and protocols.",severity:"info",line:0,colStart:0,colEnd:n[0]?.length||0,ruleCategory:"meta"})}static checkOpenGraph(e,c,n,o,i){let t=c.match(/<meta\s+[^>]*property=["']og:title["'][^>]*content=["']([^"']*)["']/i),s=c.match(/<meta\s+[^>]*property=["']og:image["'][^>]*content=["']([^"']*)["']/i),a=c.match(/<meta\s+[^>]*property=["']og:description["'][^>]*content=["']([^"']*)["']/i);t&&(i.ogTitle=t[1]),s&&(i.ogImage=s[1]),a&&(i.ogDescription=a[1]),(!t||!s)&&o.push({id:"og-tags-incomplete",code:"SEO-OG-01",message:`Incomplete OpenGraph tags: ${t?"":"og:title missing; "}${s?"":"og:image missing;"}`,recommendation:"Add og:title and og:image meta tags to ensure eye-catching preview cards on LinkedIn, X/Twitter, and Facebook.",severity:"info",line:0,colStart:0,colEnd:n[0]?.length||0,ruleCategory:"social"})}static checkJsonLd(e,c,n,o,i){let t=c.matchAll(/<script\s+[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi);for(let s of t){i.hasJsonLd=!0;let a=s[1].trim();try{JSON.parse(a)}catch(r){o.push({id:"jsonld-invalid-syntax",code:"SEO-SCHEMA-01",message:`Invalid Schema.org JSON-LD syntax: ${r.message}`,recommendation:"Verify your Schema.org structured data JSON syntax to ensure Google Rich Snippets can parse it correctly.",severity:"error",line:0,colStart:0,colEnd:n[0]?.length||0,ruleCategory:"social"})}}}static calculateScore(e,c){let n=100;for(let o of e)o.severity==="error"?n-=20:o.severity==="warning"?n-=8:o.severity==="info"&&(n-=2);return Math.max(0,Math.min(100,n))}static calculateGrade(e){return e>=95?"A+":e>=85?"A":e>=70?"B":e>=55?"C":e>=40?"D":"F"}};var k=$(require("vscode")),L=class{diagnosticCollection;constructor(){this.diagnosticCollection=k.languages.createDiagnosticCollection("seowebchecker")}updateDiagnostics(e,c){let n=[];for(let o of c.issues){let i=Math.min(Math.max(0,o.line),Math.max(0,e.lineCount-1)),t=e.lineAt(i).text,s=Math.min(Math.max(0,o.colStart),t.length),a=Math.max(s+1,Math.min(Math.max(s+1,o.colEnd),t.length)),r=new k.Range(new k.Position(i,s),new k.Position(i,a)),d=k.DiagnosticSeverity.Information;o.severity==="error"?d=k.DiagnosticSeverity.Error:o.severity==="warning"&&(d=k.DiagnosticSeverity.Warning);let p=new k.Diagnostic(r,`${o.message} \u2014 ${o.recommendation}`,d);p.source="SEOWebChecker",p.code={value:o.code,target:k.Uri.parse("https://seowebchecker.com/")},n.push(p)}this.diagnosticCollection.set(e.uri,n)}clearDiagnostics(e){this.diagnosticCollection.delete(e)}dispose(){this.diagnosticCollection.dispose()}};var C=$(require("vscode")),R=class{statusBarItem;currentResult;constructor(){this.statusBarItem=C.window.createStatusBarItem(C.StatusBarAlignment.Right,100),this.statusBarItem.command="seowebchecker.openQuickActions"}update(e){this.currentResult=e;let c=e.issues.filter(a=>a.severity==="error").length,n=e.issues.filter(a=>a.severity==="warning").length,o=e.issues.length,i="$(search)",t=new C.ThemeColor("statusBarItem.foreground");c>0?(i="$(error)",t=new C.ThemeColor("statusBarItem.errorForeground")):n>0?(i="$(warning)",t=new C.ThemeColor("statusBarItem.warningForeground")):e.score>=90&&(i="$(check)"),this.statusBarItem.text=`${i} SEO: ${e.score}/100 (${e.grade})`,this.statusBarItem.color=t;let s=new C.MarkdownString;s.isTrusted=!0,s.appendMarkdown(`### \u{1F50D} SEOWebChecker Live Audit

`),s.appendMarkdown(`**Score**: **${e.score}/100** (Grade: **${e.grade}**)

`),s.appendMarkdown(`* **Issues**: ${c} Errors, ${n} Warnings, ${o} Total
`),s.appendMarkdown(`* **Title**: ${e.stats.titleLength>0?`${e.stats.titleLength} chars`:"\u274C Missing"}
`),s.appendMarkdown(`* **Meta Description**: ${e.stats.descriptionLength>0?`${e.stats.descriptionLength} chars`:"\u274C Missing"}
`),s.appendMarkdown(`* **Headings**: H1 (${e.stats.h1Count}), H2 (${e.stats.h2Count}), H3 (${e.stats.h3Count})
`),s.appendMarkdown(`* **Images**: ${e.stats.totalImages} total (${e.stats.missingAltImages} missing alt)
`),s.appendMarkdown(`* **Word Count**: ${e.stats.wordCount} words

`),s.appendMarkdown(`---
[Open Visual SEO Audit Panel](command:seowebchecker.openDashboard) | [SEOWebChecker.com](https://seowebchecker.com/)
`),this.statusBarItem.tooltip=s,this.statusBarItem.show()}hide(){this.statusBarItem.hide()}dispose(){this.statusBarItem.dispose()}};var E=$(require("vscode")),P=class{provideHover(e,c,n){let o=e.getWordRangeAtPosition(c,/<[^>]+>|!\[.*?\]\(.*?\)/);if(!o)return null;let i=e.getText(o);if(/<(img|Image)\b/i.test(i)||/^!\[/.test(i)){let t=/\balt\s*=\s*(["'][^"']*["']|\{[^}]*\})/i.test(i)||/^!\[(.+)\]/.test(i),s=i.match(/\balt\s*=\s*["']([^"']*)["']/i)||i.match(/^!\[(.*?)\]/),a=s?s[1]:"",r=new E.MarkdownString;return r.isTrusted=!0,r.appendMarkdown(`### \u{1F5BC}\uFE0F SEOWebChecker: Image Accessibility & SEO

`),t&&a.length>0?(r.appendMarkdown(`\u2705 **Alt Text Detected**: \`"${a}"\` (${a.length} chars)

`),r.appendMarkdown(`* Helps search engines understand the image content for image search ranking.
`),r.appendMarkdown(`* Read aloud by screen readers for accessibility compliance.
`)):(r.appendMarkdown(`\u26A0\uFE0F **Missing Alt Text!**

`),r.appendMarkdown("* Without an `alt` attribute, screen readers cannot describe this image.\n"),r.appendMarkdown(`* Search crawlers cannot index this visual asset effectively.

`),r.appendMarkdown('**Recommendation**: Add `alt="descriptive text"` describing the image subject.\n')),r.appendMarkdown(`
---
[SEO Best Practices](https://seowebchecker.com/)`),new E.Hover(r,o)}if(/<title\b/i.test(i)){let t=i.match(/<title[^>]*>([\s\S]*?)<\/title>/i),s=t?t[1].trim():"",a=new E.MarkdownString;return a.isTrusted=!0,a.appendMarkdown(`### \u{1F3F7}\uFE0F SEOWebChecker: Title Tag Inspector

`),a.appendMarkdown(`**Current Length**: **${s.length}** characters (Recommended: **30\u201360**)

`),s.length>=30&&s.length<=60?a.appendMarkdown(`\u2705 **Optimal length for Google desktop & mobile search snippets.**

`):s.length<30?a.appendMarkdown(`\u26A0\uFE0F **Too short**: Consider adding your primary keyword or brand to maximize click-through rate.

`):a.appendMarkdown(`\u26A0\uFE0F **Too long**: Search engines may truncate this title with an ellipsis (...).

`),a.appendMarkdown(`---
[Title Tag Optimization Guide](https://seowebchecker.com/)`),new E.Hover(a,o)}if(/<h1\b/i.test(i)||/^#\s+/.test(i)){let t=new E.MarkdownString;return t.isTrusted=!0,t.appendMarkdown(`### \u{1F4D1} SEOWebChecker: Primary Heading (H1)

`),t.appendMarkdown("* The `<h1>` tag represents the single top-level concept of the page.\n"),t.appendMarkdown("* Having exactly **one** `<h1>` per page is recommended for clean document outline and topic authority.\n"),t.appendMarkdown(`
---
[Heading Hierarchy Guide](https://seowebchecker.com/)`),new E.Hover(t,o)}if(/name=["']description["']/i.test(i)){let t=i.match(/content=["']([^"']*)["']/i),s=t?t[1]:"",a=new E.MarkdownString;return a.isTrusted=!0,a.appendMarkdown(`### \u{1F4DD} SEOWebChecker: Meta Description Inspector

`),a.appendMarkdown(`**Current Length**: **${s.length}** characters (Recommended: **70\u2013160**)

`),s.length>=70&&s.length<=160?a.appendMarkdown(`\u2705 **Optimal snippet length for organic search results.**

`):s.length<70?a.appendMarkdown(`\u26A0\uFE0F **Too short**: Provide a more comprehensive summary to entice searchers.

`):a.appendMarkdown(`\u26A0\uFE0F **Too long**: Content after ~160 characters will likely be cut off by search engines.

`),a.appendMarkdown(`---
[Meta Description Guide](https://seowebchecker.com/)`),new E.Hover(a,o)}return null}};var f=$(require("vscode")),D=class{constructor(e){this.getConfig=e}getConfig;static providedCodeActionKinds=[f.CodeActionKind.QuickFix];provideCodeActions(e,c,n,o){let i=[],t=e.lineAt(c.start.line).text;for(let s of n.diagnostics){if(s.source!=="SEOWebChecker")continue;let a=typeof s.code=="object"?s.code.value:s.code;if(a==="SEO-IMG-01"){let d=new f.CodeAction('Add empty alt="" attribute for image',f.CodeActionKind.QuickFix);d.edit=new f.WorkspaceEdit;let p=t.match(/<(img|Image)\b[^>]*>/i);if(p){let u=new f.Position(c.start.line,t.indexOf(p[0])+p[0].length-1);d.edit.insert(e.uri,u,' alt=""'),d.isPreferred=!0,d.diagnostics=[s],i.push(d)}}if(a==="SEO-LINK-01"){let d=new f.CodeAction('Add rel="noopener noreferrer" for security & SEO',f.CodeActionKind.QuickFix);d.edit=new f.WorkspaceEdit;let p=t.match(/<a\b[^>]*>/i);if(p){let u=new f.Position(c.start.line,t.indexOf(p[0])+p[0].length-1);d.edit.insert(e.uri,u,' rel="noopener noreferrer"'),d.isPreferred=!0,d.diagnostics=[s],i.push(d)}}let r=new f.CodeAction(`Learn how to resolve ${a} on SEOWebChecker`,f.CodeActionKind.QuickFix);r.command={title:"Open SEOWebChecker Documentation",command:"vscode.open",arguments:[f.Uri.parse("https://seowebchecker.com/")]},i.push(r)}return i}};var S=$(require("vscode")),M=class h{static currentPanel;panel;disposables=[];static createOrShow(e,c){let n=S.window.activeTextEditor?S.ViewColumn.Beside:S.ViewColumn.One;if(h.currentPanel){h.currentPanel.panel.reveal(n),h.currentPanel.update(c);return}let o=S.window.createWebviewPanel("seowebcheckerAudit","SEOWebChecker Audit",n,{enableScripts:!0,retainContextWhenHidden:!0});h.currentPanel=new h(o,e,c)}constructor(e,c,n){this.panel=e,this.panel.onDidDispose(()=>this.dispose(),null,this.disposables),this.update(n),this.panel.webview.onDidReceiveMessage(o=>{switch(o.command){case"openExternal":S.env.openExternal(S.Uri.parse(o.url));return;case"copyMarkdown":S.env.clipboard.writeText(o.text),S.window.showInformationMessage("SEOWebChecker Markdown report copied to clipboard!");return}},null,this.disposables)}update(e){this.panel.title=`SEO: ${e.fileName}`,this.panel.webview.html=this.getHtmlForWebview(e)}dispose(){for(h.currentPanel=void 0,this.panel.dispose();this.disposables.length;){let e=this.disposables.pop();e&&e.dispose()}}getHtmlForWebview(e){let c=e.grade==="A+"||e.grade==="A"?"#10b981":e.grade==="B"?"#3b82f6":e.grade==="C"?"#f59e0b":"#ef4444",n=e.issues.length===0?'<div class="empty-state">\u{1F389} Outstanding! No technical SEO issues detected in this file.</div>':e.issues.map(t=>`
          <div class="issue-card ${t.severity}">
            <div class="issue-header">
              <span class="badge ${t.severity}">${t.severity.toUpperCase()}</span>
              <span class="issue-code">${t.code}</span>
              <span class="issue-line">Line ${t.line+1}</span>
            </div>
            <div class="issue-msg">${this.escapeHtml(t.message)}</div>
            <div class="issue-recom">\u{1F4A1} <strong>Remediation:</strong> ${this.escapeHtml(t.recommendation)}</div>
          </div>
        `).join(""),o=e.stats.title||"Untitled Document",i=e.stats.description||"No meta description provided for this page snippet...";return`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SEOWebChecker Audit</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      padding: 24px;
      color: var(--vscode-foreground);
      background-color: var(--vscode-editor-background);
      line-height: 1.5;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px solid var(--vscode-widget-border, #333);
      padding-bottom: 16px;
      margin-bottom: 24px;
    }
    .header h1 {
      margin: 0;
      font-size: 20px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .score-banner {
      display: flex;
      align-items: center;
      gap: 24px;
      background: var(--vscode-editor-inactiveSelectionBackground, rgba(255,255,255,0.05));
      border: 1px solid var(--vscode-widget-border, #444);
      border-radius: 12px;
      padding: 20px 24px;
      margin-bottom: 24px;
    }
    .score-circle {
      width: 72px;
      height: 72px;
      border-radius: 50%;
      background: ${c};
      color: #fff;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      font-weight: 800;
      font-size: 22px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }
    .score-circle span {
      font-size: 11px;
      font-weight: normal;
      opacity: 0.9;
    }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
      gap: 12px;
      margin-bottom: 24px;
    }
    .stat-box {
      background: var(--vscode-editor-inactiveSelectionBackground, rgba(255,255,255,0.04));
      border: 1px solid var(--vscode-widget-border, #333);
      border-radius: 8px;
      padding: 12px 14px;
      text-align: center;
    }
    .stat-val {
      font-size: 18px;
      font-weight: 700;
      color: var(--vscode-textLink-foreground, #38bdf8);
    }
    .stat-lbl {
      font-size: 11px;
      opacity: 0.8;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-top: 4px;
    }
    .serp-card {
      background: var(--vscode-editor-inactiveSelectionBackground, rgba(255,255,255,0.03));
      border: 1px solid var(--vscode-widget-border, #333);
      border-radius: 10px;
      padding: 18px;
      margin-bottom: 24px;
    }
    .serp-url {
      font-size: 12px;
      color: #10b981;
      margin-bottom: 4px;
      word-break: break-all;
    }
    .serp-title {
      font-size: 17px;
      color: #3b82f6;
      font-weight: 600;
      text-decoration: none;
      display: block;
      margin-bottom: 6px;
    }
    .serp-desc {
      font-size: 13px;
      color: var(--vscode-foreground);
      opacity: 0.85;
      line-height: 1.4;
    }
    .issue-card {
      background: var(--vscode-editor-inactiveSelectionBackground, rgba(255,255,255,0.03));
      border: 1px solid var(--vscode-widget-border, #333);
      border-left: 4px solid #888;
      border-radius: 8px;
      padding: 14px 16px;
      margin-bottom: 12px;
    }
    .issue-card.error { border-left-color: #ef4444; }
    .issue-card.warning { border-left-color: #f59e0b; }
    .issue-card.info { border-left-color: #3b82f6; }
    .issue-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 6px;
    }
    .badge {
      font-size: 10px;
      font-weight: 700;
      padding: 2px 6px;
      border-radius: 4px;
      color: #fff;
    }
    .badge.error { background: #ef4444; }
    .badge.warning { background: #f59e0b; color: #111; }
    .badge.info { background: #3b82f6; }
    .issue-code { font-family: monospace; font-size: 11px; opacity: 0.8; }
    .issue-line { font-size: 11px; opacity: 0.6; margin-left: auto; }
    .issue-msg { font-weight: 600; font-size: 13px; margin-bottom: 4px; }
    .issue-recom { font-size: 12px; opacity: 0.85; }
    .btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 8px 14px;
      border-radius: 6px;
      background: var(--vscode-button-background);
      color: var(--vscode-button-foreground);
      text-decoration: none;
      cursor: pointer;
      font-size: 12px;
      font-weight: 600;
      border: none;
    }
    .btn:hover { background: var(--vscode-button-hoverBackground); }
    .btn-outline {
      background: transparent;
      border: 1px solid var(--vscode-button-background);
      color: var(--vscode-foreground);
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>\u{1F50D} SEOWebChecker Visual Audit</h1>
    <div style="display: flex; gap: 8px;">
      <button class="btn btn-outline" onclick="copyReport()">\u{1F4CB} Copy Markdown</button>
      <button class="btn" onclick="openPlatform()">\u{1F310} SEOWebChecker.com</button>
    </div>
  </div>

  <div class="score-banner">
    <div class="score-circle">
      ${e.score}
      <span>GRADE ${e.grade}</span>
    </div>
    <div>
      <h2 style="margin: 0 0 4px 0; font-size: 16px;">Technical SEO Health Score</h2>
      <p style="margin: 0; opacity: 0.8; font-size: 13px;">
        Evaluated <strong>${e.fileName}</strong> across title tags, descriptions, headings, image alt accessibility, and link security.
      </p>
    </div>
  </div>

  <div class="stats-grid">
    <div class="stat-box">
      <div class="stat-val">${e.stats.titleLength}</div>
      <div class="stat-lbl">Title Length</div>
    </div>
    <div class="stat-box">
      <div class="stat-val">${e.stats.descriptionLength}</div>
      <div class="stat-lbl">Meta Desc Chars</div>
    </div>
    <div class="stat-box">
      <div class="stat-val">${e.stats.h1Count}</div>
      <div class="stat-lbl">H1 Headings</div>
    </div>
    <div class="stat-box">
      <div class="stat-val">${e.stats.totalImages} (${e.stats.missingAltImages} missing)</div>
      <div class="stat-lbl">Image Alts</div>
    </div>
    <div class="stat-box">
      <div class="stat-val">${e.stats.wordCount}</div>
      <div class="stat-lbl">Word Count</div>
    </div>
  </div>

  <div class="serp-card">
    <h3 style="margin: 0 0 10px 0; font-size: 13px; opacity: 0.8; text-transform: uppercase; letter-spacing: 0.5px;">Google SERP Snippet Preview</h3>
    <div class="serp-url">${e.stats.canonicalUrl||"https://example.com/page"}</div>
    <div class="serp-title">${this.escapeHtml(o)}</div>
    <div class="serp-desc">${this.escapeHtml(i)}</div>
  </div>

  <h3 style="margin: 24px 0 12px 0; font-size: 15px;">Diagnostic Checks & Issues (${e.issues.length})</h3>
  <div class="issues-list">
    ${n}
  </div>

  <script>
    const vscode = acquireVsCodeApi();
    function openPlatform() {
      vscode.postMessage({ command: 'openExternal', url: 'https://seowebchecker.com/' });
    }
    function copyReport() {
      const markdown = \`# SEOWebChecker Audit Report
**File**: ${e.fileName}
**Score**: ${e.score}/100 (Grade ${e.grade})
**Audited**: ${e.scannedAt}

## Key Metrics
- Title Tag: ${e.stats.titleLength} characters
- Meta Description: ${e.stats.descriptionLength} characters
- H1 Headings: ${e.stats.h1Count}
- Images: ${e.stats.totalImages} total (${e.stats.missingAltImages} missing alt)
- Word Count: ${e.stats.wordCount} words

## Diagnostic Issues
${e.issues.map(t=>`- [${t.severity.toUpperCase()}] ${t.code}: ${t.message}`).join(`
`)}

Generated by SEOWebChecker: https://seowebchecker.com/\`;
      vscode.postMessage({ command: 'copyMarkdown', text: markdown });
    }
  </script>
</body>
</html>`}escapeHtml(e){return e.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#039;")}};var A,O,m,W=["html","javascriptreact","typescriptreact","astro","vue","svelte","php","markdown","mdx"];function F(h){A=new L,O=new R,h.subscriptions.push(A),h.subscriptions.push(O);let e=()=>{let o=l.workspace.getConfiguration("seowebchecker");return{minTitleLength:o.get("minTitleLength",30),maxTitleLength:o.get("maxTitleLength",60),minDescriptionLength:o.get("minDescriptionLength",70),maxDescriptionLength:o.get("maxDescriptionLength",160),checkHeadings:o.get("checkHeadings",!0),checkImages:o.get("checkImages",!0),checkLinks:o.get("checkLinks",!0),checkOpenGraph:o.get("checkOpenGraph",!0),checkCanonical:o.get("checkCanonical",!0),checkMobileViewport:o.get("checkMobileViewport",!0),checkThinContent:o.get("checkThinContent",!0),minWordCount:o.get("minWordCount",300),enableStatusBar:o.get("enableStatusBar",!0),enableHover:o.get("enableHover",!0)}},c=o=>{if(W.includes(o.languageId))return!0;let i=o.fileName.split(".").pop()?.toLowerCase();return["html","htm","jsx","tsx","astro","vue","svelte","php","md","mdx"].includes(i||"")},n=o=>{if(!c(o)){O.hide();return}let i=e();m=T.analyzeDocument(o,i),A.updateDiagnostics(o,m),i.enableStatusBar?O.update(m):O.hide(),M.currentPanel&&M.currentPanel.update(m)};h.subscriptions.push(l.window.onDidChangeActiveTextEditor(o=>{o?n(o.document):O.hide()}),l.workspace.onDidChangeTextDocument(o=>{l.window.activeTextEditor?.document===o.document&&n(o.document)}),l.workspace.onDidSaveTextDocument(o=>{n(o)}),l.workspace.onDidCloseTextDocument(o=>{A.clearDiagnostics(o.uri)}));for(let o of W)h.subscriptions.push(l.languages.registerHoverProvider(o,new P));for(let o of W)h.subscriptions.push(l.languages.registerCodeActionsProvider(o,new D(e),{providedCodeActionKinds:D.providedCodeActionKinds}));h.subscriptions.push(l.commands.registerCommand("seowebchecker.runAudit",()=>{let o=l.window.activeTextEditor;if(!o){l.window.showWarningMessage("Please open an HTML, JSX, TSX, Astro, or Markdown file to run an SEO audit.");return}if(n(o.document),m){let i=`SEOWebChecker: Scored ${m.score}/100 (${m.grade}) with ${m.issues.length} diagnostic issues.`;m.score>=85?l.window.showInformationMessage(i,"View Visual Report").then(t=>{t==="View Visual Report"&&l.commands.executeCommand("seowebchecker.openDashboard")}):l.window.showWarningMessage(i,"View Visual Report").then(t=>{t==="View Visual Report"&&l.commands.executeCommand("seowebchecker.openDashboard")})}})),h.subscriptions.push(l.commands.registerCommand("seowebchecker.openDashboard",()=>{let o=l.window.activeTextEditor;if(!o){l.window.showWarningMessage("Please open a file to view its SEO audit report.");return}(!m||m.fileName!==o.document.fileName)&&(m=T.analyzeDocument(o.document,e())),M.createOrShow(h.extensionUri,m)})),h.subscriptions.push(l.commands.registerCommand("seowebchecker.openQuickActions",async()=>{if(!m){let s=l.window.activeTextEditor;s&&n(s.document)}let i=[{label:"$(graph) Open Visual SEO Audit Panel",description:m?`Current Score: ${m.score}/100 (Grade ${m.grade})`:"Run Audit",detail:"Shows circular score gauge, SERP snippet preview, and category breakdown."},{label:"$(list-unordered) Focus Problems Panel",detail:"View all highlighted SEO issues and code locations in the Problems tray."},{label:"$(markdown) Export Report as Markdown",detail:"Creates a clean markdown summary of issues and recommendations."},{label:"$(json) Export Report as JSON",detail:"Exports raw diagnostic metrics and issue payloads."},{label:"$(globe) Open SEOWebChecker Platform",detail:"Access full domain crawls, historic tracking, and Core Web Vitals at https://seowebchecker.com/"}],t=await l.window.showQuickPick(i,{placeHolder:"SEOWebChecker: Select an SEO Action"});t&&(t.label.includes("Visual SEO Audit Panel")?l.commands.executeCommand("seowebchecker.openDashboard"):t.label.includes("Focus Problems Panel")?l.commands.executeCommand("workbench.actions.view.problems"):t.label.includes("Export Report as Markdown")?l.commands.executeCommand("seowebchecker.exportMarkdown"):t.label.includes("Export Report as JSON")?l.commands.executeCommand("seowebchecker.exportJson"):t.label.includes("Open SEOWebChecker Platform")&&l.env.openExternal(l.Uri.parse("https://seowebchecker.com/")))})),h.subscriptions.push(l.commands.registerCommand("seowebchecker.exportMarkdown",async()=>{if(!m){l.window.showWarningMessage("No active SEO audit available to export.");return}let o=`# Technical SEO Audit Report: ${m.fileName}

- **Platform Reference**: https://seowebchecker.com/
- **SEO Health Score**: **${m.score}/100** (Grade: **${m.grade}**)
- **Audited At**: ${m.scannedAt}

## Key Metrics
- **Title Tag**: ${m.stats.titleLength>0?`${m.stats.titleLength} characters ("${m.stats.title}")`:"Missing"}
- **Meta Description**: ${m.stats.descriptionLength>0?`${m.stats.descriptionLength} characters`:"Missing"}
- **Heading Hierarchy**: H1: ${m.stats.h1Count}, H2: ${m.stats.h2Count}, H3: ${m.stats.h3Count}
- **Images**: ${m.stats.totalImages} total (${m.stats.missingAltImages} missing alt attributes)
- **Links**: ${m.stats.totalLinks} total (${m.stats.externalLinksWithoutSecurity} insecure external links)
- **Word Count**: ${m.stats.wordCount} words

## Diagnostic Issues (${m.issues.length})
${m.issues.length===0?"_No issues detected! Excellent on-page SEO._":m.issues.map(t=>`### [${t.severity.toUpperCase()}] ${t.code} (Line ${t.line+1})
- **Issue**: ${t.message}
- **Remediation**: ${t.recommendation}
`).join(`
`)}

---
_Generated by SEOWebChecker VS Code Extension. Visit [SEOWebChecker.com](https://seowebchecker.com/) for comprehensive site monitoring._
`,i=await l.workspace.openTextDocument({content:o,language:"markdown"});await l.window.showTextDocument(i)})),h.subscriptions.push(l.commands.registerCommand("seowebchecker.exportJson",async()=>{if(!m){l.window.showWarningMessage("No active SEO audit available to export.");return}let o=JSON.stringify(m,null,2),i=await l.workspace.openTextDocument({content:o,language:"json"});await l.window.showTextDocument(i)})),l.window.activeTextEditor&&n(l.window.activeTextEditor.document)}function J(){A&&A.dispose(),O&&O.dispose()}0&&(module.exports={activate,deactivate});
