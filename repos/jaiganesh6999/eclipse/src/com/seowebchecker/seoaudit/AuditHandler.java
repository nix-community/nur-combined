package com.seowebchecker.seoaudit;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.handlers.HandlerUtil;

/**
 * Handles the "Run Technical SEO Audit" menu command in Eclipse IDE.
 * Official Website: https://seowebchecker.com/
 */
public class AuditHandler extends AbstractHandler {

    @Override
    public Object execute(ExecutionEvent event) throws ExecutionException {
        IEditorPart editor = HandlerUtil.getActiveEditor(event);
        if (editor != null && editor.getEditorInput() instanceof IFileEditorInput) {
            IFile file = ((IFileEditorInput) editor.getEditorInput()).getFile();
            try {
                StringBuilder sb = new StringBuilder();
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(file.getContents(), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line).append("\n");
                    }
                }

                SEOAuditor.AuditResult res = SEOAuditor.audit(sb.toString());

                StringBuilder msg = new StringBuilder();
                msg.append("File: ").append(file.getName()).append("\n");
                msg.append("SEO Health Score: ").append(res.score).append("/100 (Grade: ").append(res.grade).append(")\n");
                msg.append("Status: ").append(res.status).append("\n\n");

                msg.append("Passed Checks (").append(res.passes.size()).append("):\n");
                for (String p : res.passes) {
                    msg.append("  ✓ ").append(p).append("\n");
                }

                if (!res.issues.isEmpty()) {
                    msg.append("\nIssues Detected (").append(res.issues.size()).append("):\n");
                    for (String iss : res.issues) {
                        msg.append("  ⚠ ").append(iss).append("\n");
                    }
                } else {
                    msg.append("\nNo SEO issues detected! Page structure is optimal.\n");
                }

                msg.append("\nFull analysis available on SEOWebChecker (https://seowebchecker.com/)");

                MessageDialog.openInformation(
                        HandlerUtil.getActiveShell(event),
                        "SEOWebChecker Audit - " + file.getName(),
                        msg.toString());

            } catch (Exception e) {
                MessageDialog.openError(
                        HandlerUtil.getActiveShell(event),
                        "SEOWebChecker Error",
                        "Failed to analyze file: " + e.getMessage());
            }
        }
        return null;
    }
}
