package embl.almf;

/* Kota Miura (cmci.embl.de)
 * 20121121
 */
import java.io.File;
import java.io.IOException;

import ij.IJ;
import ij.ImagePlus;

public class ProcessOnNewFile extends AbsMonitorFolderFiles {

	final String watchpath;
	String microscope = "";
	Microscope_Communicator mc = null;
	int fileaccessCounter = 0;
	static final int maxframenumber = 3;
	
	/**
	 * @param watchpath
	 * @param microscope
	 */
	public ProcessOnNewFile(String watchpath, String microscope) {
		super();
		this.watchpath = watchpath;
		this.microscope = microscope;
		if (!this.checkDirExists(watchpath)){
				IJ.error(watchpath + " does not exist");
				return;
		}
		mc = new Microscope_Communicator();
		mc.setMicroscope(microscope);
		//mc.setFilepath(watchpath);
	}

	/** This method is triggered when a file is changed in watchpath.
	 * 
	 */
	@Override
	void runOnChangedFile(File file) {
		runOnNewFile(file);
	}
	
	/** This method is triggered when a file is added to the watchpath.
	 * 
	 */
	@Override
	void runOnNewFile(File file) {
		String fullpath = "";
		try {
			fullpath = file.getCanonicalPath();         
        } catch (IOException e) {
            e.printStackTrace(System.err);
        }
        IJ.log("File created: " + fullpath);
        ImagePlus imp = IJ.openImage(fullpath);
        mc.setFilepath(fullpath);
        
        // here, need to make decision using probability examinations. 
//        if (decision)
//        	mc.image_selected_particle(int offsetx, int offsety);
//        else
//        	mc.do_nothing();
        IJ.log("retrieved newly added file");
        
        // stop monitoring after several rounds, this should be controllable from outside at some point. 
        fileaccessCounter += 1;
        if (fileaccessCounter > maxframenumber){
			this.stopMonitor();
			IJ.log("Stopped Monitoring");
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
	 String tmppath = "C:\\FolderName\\";
	 String tmpmicroscope = "File system";
	 AbsMonitorFolderFiles mff = new ProcessOnNewFile(tmppath, tmpmicroscope);
	 try {
		 mff.startMonitoring();
	 } catch (Exception e) {
		 // TODO Auto-generated catch block
		 e.printStackTrace();
	 }
//	 IJ.wait(10000);
//	 mff.stopMonitor();
 }	
// class SimpleThreadFactory implements ThreadFactory {
//	   public Thread newThread(Runnable r) {
//	     return new Thread(r);
//	   }
//	 } 

//	@Override
//	public void run(String path) {
//		if (path != null){
//			setFOLDER(path);
//		}
//		AbsMonitorFolderFiles mff = new ProcessOnNewFile();
//		try {
//			mff.startMonitoring();
//		} catch (Exception e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//
//	}
 
}
