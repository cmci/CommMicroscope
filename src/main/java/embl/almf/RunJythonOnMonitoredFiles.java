package embl.almf;
//Kota Miura (cmci.embl.de)
//20121122

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import org.apache.commons.io.monitor.FileAlterationMonitor;

import common.ScriptRunner;

import ij.IJ;
import ij.gui.GenericDialog;
import ij.io.OpenDialog;
import ij.macro.MacroRunner;
import ij.plugin.PlugIn;

public class RunJythonOnMonitoredFiles extends AbsMonitorFolderFiles implements ActionListener{
	boolean okpushed, cancelpushed;
	JFrame Dialog;
	JButton bt_open1, bt_open2, bt_ok, bt_cancel;
	JTextField directory, macrotorun;
	
	String watchpath;
	String jythonpath = "/Users/miura/Desktop/tmp/testjy.py";
	int maxrun = Integer.MAX_VALUE;
	String monitor_threadname = "";
	int runcount =0;
	RunJythonOnMonitoredFiles mff;
    private String latestFileName = "";	
	
	private volatile Thread monitorthread;
	
	public RunJythonOnMonitoredFiles(){
		super();
		//this.watchpath = "/Users/miura/Desktop/tmp/watch";
	}
	
	public RunJythonOnMonitoredFiles(String macropath){
		super();
		this.jythonpath = macropath;
		this.watchpath = "/Users/miura/Desktop/tmp/watch";
		//macrotext = IJ.openAsString(this.jythonpath);
	}
	public boolean checkMacroFileExists(String FOLDER){
		File f = new File(FOLDER);
		return f.exists();
	}

	public void execute() {
		if (dialog()){	
			try {
				this.startMonitoring();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else {
			IJ.error("Path assignment failed! Check paths again...");
		}
	}	
	public void actionPerformed(ActionEvent e) {
		if (e.getSource() == bt_open1) {
			//Do something
			//IJ.log("pushed open1");
			this.watchpath = IJ.getDirectory(""); ;
			setWatchpath(this.watchpath);
			directory.setText(this.watchpath);
		}
		if (e.getSource() == bt_open2) {
			//Do something
			//IJ.log("pushed open1");
			OpenDialog od = new OpenDialog("Choose a .mrc file", null); 
			this.jythonpath =  od.getDirectory() + od.getFileName();
			//this.watchpath =
			macrotorun.setText(this.jythonpath);
		}
		if (e.getSource() == bt_ok) {
			//Do something
			//IJ.log("pushed Ok");
			//check for folder and macropath
			if (!checkMacroFileExists(jythonpath)) {
				IJ.log("No such macro file: " + this.jythonpath);
			}
			if (!checkDirExists(watchpath)){
				IJ.log("No such directory to watch: " + this.watchpath);			
			}
			if (checkMacroFileExists(jythonpath) && checkDirExists(watchpath)) {
				Dialog.dispose();
				okpushed = true;
			}
				
		}
		if (e.getSource() == bt_cancel) {
			//Do something
			//IJ.log("pushed cancel");
			cancelpushed = true;
			Dialog.dispose();
			//Macro.abort();
		}
		
	}
	@Override
	void runOnChangedFile(File file) {
		runOnNewFile(file);
	}
	
	@Override
	void runOnNewFile(File file) {

		String addedfilepath = "";
		try {
			addedfilepath = file.getCanonicalPath();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		this.setLatestFileName(addedfilepath);
		HashMap<String, Object> arg = new HashMap<String, Object>();
		arg.put("newImagePath", addedfilepath);
		ScriptRunner.runPY(this.jythonpath, arg);

		this.runcount += 1;
        if (this.runcount >= maxrun ){
        	IJ.log("monitoring stopped: " + Integer.toString(runcount) + " iterations.");
        	try {
        		this.stopMonitor();
    		} catch (Exception e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		}
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
	
	public void setRunMax(int maxrun){
		this.maxrun = maxrun;
	}
	
	public void setMacroFile(String macrofilepath){
		this.jythonpath = macrofilepath;
	}

	
	public boolean dialog(){
		Font font1 = new Font("Default", Font.PLAIN, 12);
		Font font1small = new Font("DefaultSmall", Font.PLAIN, 12);		
		//creates the dialog
		Dialog = new JFrame("Jython Runner Settings");
		directory = new JTextField("",20);
		macrotorun = new JTextField("",20);
		JLabel labeldir = new JLabel("Directory");
		JLabel labelmacro = new JLabel("Jython");
		JLabel msg = new JLabel("Applys a jython script when a new file appears " +
				"in a monitoring directory.");
		msg.setFont(font1small);
		labeldir.setFont(font1small);
		labelmacro.setFont(font1small);
		
		//buttons
		bt_open1 = new JButton("Browse");
		bt_open1.setFont(font1);
		bt_open1.addActionListener(this);
		bt_open2 = new JButton("Browse");
		bt_open2.addActionListener(this);
		bt_open2.setFont(font1);
		bt_ok = new JButton("OK");
		bt_ok.setFont(font1);
		bt_cancel = new JButton("Cancel");
		bt_cancel.setFont(font1);
		bt_ok.addActionListener(this);
		bt_cancel.addActionListener(this);
		
		//dialog panels
		JPanel topp = new JPanel();
		topp.add(msg);
		
		JPanel upperp = new JPanel();
		upperp.setLayout(new FlowLayout(1,5,0));
		upperp.add(labeldir);
		upperp.add(directory);
		upperp.add(bt_open1);
		
		JPanel middlep = new JPanel();
		middlep.setLayout(new FlowLayout(1,5,0));
		middlep.add(labelmacro);
		middlep.add(macrotorun);
		middlep.add(bt_open2);
		
		JPanel lowerp = new JPanel();
		lowerp.setLayout(new FlowLayout(1,5,0));
		lowerp.add(bt_ok);
		lowerp.add(bt_cancel);
		
		JPanel fullp = new JPanel();
		fullp.setLayout(new GridLayout(4,1));
		fullp.add(topp);
		fullp.add(upperp);
		fullp.add(middlep);
		fullp.add(lowerp);
		
		Dialog.getContentPane().add(fullp, BorderLayout.CENTER);
		Dialog.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		Dialog.setSize(450, 200);
		Dialog.setVisible(true);
		
		//do different things depending what has been pushed on dialog
		if (Dialog == null)
			cancelpushed = true;
		
		while( !cancelpushed && !okpushed ) {
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		if (okpushed) {
			//check a last time
			if (!checkMacroFileExists(this.jythonpath) || !checkDirExists(this.watchpath))  {
				IJ.error("Path assignment failed! Check paths again...");
				//Macro.abort();
			}
			
			return true;
		}
		
		return false;
		
	}
	
	
	public String getLatestFileName() {
		return latestFileName;
	}

	public void setLatestFileName(String latestFileName) {
		this.latestFileName = latestFileName;
		super.notifyObservers();
	}

/** for debugging
  * 
  * @param args
  */
 public static void main(String[] args) {
	RunJythonOnMonitoredFiles mff = new RunJythonOnMonitoredFiles();
	mff.execute();
 	
 }	

}
