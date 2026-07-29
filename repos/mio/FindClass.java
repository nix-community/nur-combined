import java.io.File;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;
import java.util.Enumeration;
import java.io.InputStream;

public class FindClass {
    public static void main(String[] args) throws Exception {
        String dir = args[0];
        search(new File(dir));
    }
    
    static void search(File f) throws Exception {
        if (f.isDirectory()) {
            for (File c : f.listFiles()) search(c);
        } else if (f.getName().endsWith(".jar") || f.getName().endsWith(".zip")) {
            try (ZipFile zf = new ZipFile(f)) {
                Enumeration<? extends ZipEntry> entries = zf.entries();
                while (entries.hasMoreElements()) {
                    ZipEntry e = entries.nextElement();
                    if (e.getName().equals("com/intellij/util/JavaVersionShimKt.class")) {
                        System.out.println("FOUND in " + f.getAbsolutePath());
                        // Check if it contains "fleet/util/multiplatform/ExpectInMultiplatformKt"
                        InputStream is = zf.getInputStream(e);
                        byte[] bytes = is.readAllBytes();
                        String s = new String(bytes, "ISO-8859-1");
                        if (s.contains("ExpectInMultiplatformKt")) {
                            System.out.println("  -> AND it contains ExpectInMultiplatformKt!!!");
                        } else {
                            System.out.println("  -> Does NOT contain ExpectInMultiplatformKt.");
                        }
                    }
                }
            } catch (Exception e) {}
        }
    }
}
