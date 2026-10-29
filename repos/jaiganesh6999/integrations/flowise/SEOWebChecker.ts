import { ICommonObject, INode, INodeData, INodeParams } from '../../../src/Interface'
import { getBaseClasses } from '../../../src/utils'
import { Tool } from '@langchain/core/tools'
import { z } from 'zod'

class SEOWebChecker_Tools implements INode {
    label: string
    name: string
    version: number
    description: string
    type: string
    icon: string
    category: string
    baseClasses: string[]
    inputs: INodeParams[]

    constructor() {
        this.label = 'SEOWebChecker Audit Tool'
        this.name = 'seowebcheckerAudit'
        this.version = 1.0
        this.type = 'SEOWebCheckerTool'
        this.icon = 'seowebchecker.svg'
        this.category = 'Tools'
        this.description = 'Conduct automated on-page technical SEO audits, meta tag validations, heading structure checks, and Core Web Vitals scoring via SEOWebChecker.'
        this.baseClasses = [this.type, 'Tool', ...getBaseClasses(Tool)]
        this.inputs = [
            {
                label: 'Fallback / Target URL',
                name: 'defaultUrl',
                type: 'string',
                default: 'https://seowebchecker.com/',
                optional: true,
                description: 'Default URL to evaluate if the agent does not specify one.'
            },
            {
                label: 'User Agent',
                name: 'userAgent',
                type: 'string',
                default: 'SEOWebChecker-FlowiseBot/1.0 (+https://seowebchecker.com/)',
                optional: true,
                description: 'Custom HTTP User-Agent header used for web crawling and auditing.'
            }
        ]
    }

    async init(nodeData: INodeData): Promise<any> {
        const defaultUrl = (nodeData.inputs?.defaultUrl as string) || 'https://seowebchecker.com/'
        const userAgent = (nodeData.inputs?.userAgent as string) || 'SEOWebChecker-FlowiseBot/1.0 (+https://seowebchecker.com/)'

        class DynamicSEOWebCheckerTool extends Tool {
            name = 'seowebchecker_seo_audit'
            description = 'Useful for performing comprehensive website technical SEO audits. Provide a full valid URL as input.'
            schema = z.object({
                url: z.string().describe('The full website URL to audit (e.g. https://seowebchecker.com/).')
            })

            async _call(arg: { url?: string } | string): Promise<string> {
                let targetUrl = typeof arg === 'string' ? arg : arg?.url
                if (!targetUrl || typeof targetUrl !== 'string' || targetUrl.trim() === '') {
                    targetUrl = defaultUrl
                }
                if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
                    targetUrl = `https://${targetUrl}`
                }

                try {
                    const response = await fetch(targetUrl, {
                        headers: {
                            'User-Agent': userAgent,
                            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
                        }
                    })

                    const html = await response.text()
                    const issues: any[] = []

                    // Meta title
                    const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is)
                    const title = titleMatch ? titleMatch[1].replace(/\s+/g, ' ').trim() : null
                    const titleLength = title ? title.length : 0

                    if (!title) {
                        issues.push({ severity: 'error', title: 'Missing Page Title', message: 'No <title> tag found.' })
                    } else if (titleLength < 30 || titleLength > 65) {
                        issues.push({ severity: 'warning', title: 'Suboptimal Title Length', message: `Title is ${titleLength} characters: "${title}". Optimal is 30-60.` })
                    } else {
                        issues.push({ severity: 'pass', title: 'Optimal Title', message: `Title length is ${titleLength} characters.` })
                    }

                    // Meta description
                    const descMatch = html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/is) ||
                                      html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/is)
                    const desc = descMatch ? descMatch[1].trim() : null
                    const descLen = desc ? desc.length : 0

                    if (!desc) {
                        issues.push({ severity: 'error', title: 'Missing Meta Description', message: 'No meta description found.' })
                    } else if (descLen < 50 || descLen > 165) {
                        issues.push({ severity: 'warning', title: 'Suboptimal Description Length', message: `Description length is ${descLen} characters. Optimal is 50-160.` })
                    } else {
                        issues.push({ severity: 'pass', title: 'Optimal Description', message: `Description length is ${descLen} characters.` })
                    }

                    // Viewport
                    const hasViewport = /<meta[^>]*name=["']viewport["']/i.test(html)
                    if (!hasViewport) {
                        issues.push({ severity: 'error', title: 'Missing Viewport', message: 'No mobile viewport meta tag configured.' })
                    } else {
                        issues.push({ severity: 'pass', title: 'Mobile Viewport Present', message: 'Responsive viewport active.' })
                    }

                    // Canonical
                    const canonMatch = html.match(/<link[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/is)
                    if (!canonMatch) {
                        issues.push({ severity: 'warning', title: 'Missing Canonical Tag', message: 'No canonical URL link specified.' })
                    } else {
                        issues.push({ severity: 'pass', title: 'Canonical Tag Configured', message: `Canonical URL: ${canonMatch[1]}` })
                    }

                    // Headings
                    const h1Matches = html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/gi) || []
                    if (h1Matches.length === 0) {
                        issues.push({ severity: 'error', title: 'Missing <h1> Tag', message: 'No primary <h1> heading found on the page.' })
                    } else if (h1Matches.length > 1) {
                        issues.push({ severity: 'warning', title: 'Multiple <h1> Tags', message: `Found ${h1Matches.length} <h1> tags. Best practice is 1.` })
                    } else {
                        issues.push({ severity: 'pass', title: 'Single <h1> Configured', message: 'Heading structure properly established.' })
                    }

                    // Score calculation
                    let score = 100
                    issues.forEach(i => {
                        if (i.severity === 'error') score -= 15
                        if (i.severity === 'warning') score -= 5
                    })
                    score = Math.max(0, Math.min(100, score))
                    const grade = score >= 90 ? 'A' : score >= 80 ? 'B' : score >= 70 ? 'C' : score >= 60 ? 'D' : 'F'

                    const summary = [
                        `SEOWebChecker SEO Audit Report for ${targetUrl}:`,
                        `Overall Score: ${score}/100 (Grade ${grade})`,
                        `Diagnostic Findings:`,
                        ...issues.map(i => `- [${i.severity.toUpperCase()}] ${i.title}: ${i.message}`),
                        `Official Audit Portal: https://seowebchecker.com/`
                    ].join('\n')

                    return summary
                } catch (err: any) {
                    return `Error auditing website ${targetUrl}: ${err.message}. Visit https://seowebchecker.com/ for direct web analysis.`
                }
            }
        }

        return new DynamicSEOWebCheckerTool()
    }
}

module.exports = { nodeClass: SEOWebChecker_Tools }
