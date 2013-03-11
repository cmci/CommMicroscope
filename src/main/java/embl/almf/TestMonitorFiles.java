package embl.almf;

//Kota Miura (cmci.embl.de)
//20121121

import java.io.File;
import java.io.IOException;

import ij.IJ;
import ij.plugin.PlugIn;

public class TestMonitorFiles extends AbsMonitorFolderFiles {

//	@Override
//	public void run(String path) {
//		if (path != null){
//			setFOLDER(path);
//		}
//		AbsMonitorFolderFiles mff = new TestMonitorFiles();
//		try {
//			mff.startMonitoring();
//		} catch (Exception e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//
//	}
	@Override
	void runOnChangedFile(File file) {
		runOnNewFile(file);
	}
	
	@Override
	void runOnNewFile(File file) {
        try {
            // "file" is the reference to the newly created file
            IJ.log("File created: "
                    + file.getCanonicalPath());
        } catch (IOException e) {
            e.printStackTrace(System.err);
        }
		
	}

	@Override
	void runOnFileRemove(File file) {
        try {
            // "file" is the reference to the removed file
            IJ.log("File removed: "
                    + file.getCanonicalPath());
            // "file" does not exists anymore in the location
            IJ.log("File still exists in location: "
                    + file.exists());
        } catch (IOException e) {
            e.printStackTrace(System.err);
        }
		
	}
  /** for debugging
  * 
  * @param args
  */
 public static void main(String[] args) {
	 AbsMonitorFolderFiles mff = new TestMonitorFiles();
	 try {
		 mff.startMonitoring();
	 } catch (Exception e) {
		 // TODO Auto-generated catch block
		 e.printStackTrace();
	 }
	 IJ.wait(10000);
	 mff.stopMonitor();
 }	
// class SimpleThreadFactory implements ThreadFactory {
//	   public Thread newThread(Runnable r) {
//	     return new Thread(r);
//	   }
//	 } 

}
