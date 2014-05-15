package embl.almf;

import ij.IJ;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;

/**
 * @author Oleg Ryaboy, based on work by Miguel Enriquez 
 */
class WindowsRegistry {

	/**
	 * 
	 * @param location path in the registry
	 * @param key registry key
	 * @return registry value or null if not found
	 */
	
	public static final String writeRegistry(String location, String key, String value){
		try {

			String cmd = "reg add " + '"' + location + "\" /v " + key + " /d \"" + value  + '"' + " /f ";
			//IJ.log(""+cmd);
			Process process = Runtime.getRuntime().exec(cmd);

			StreamReader reader = new StreamReader(process.getInputStream());
			reader.start();
			process.waitFor();
			reader.join();
			String output = reader.getResult();
			//IJ.log(""+output);
			return "ok";
		}
		catch (Exception e) {
			return null;
		}
	}

	public static final String readRegistry(String location, String key){
		try {
			// Run reg query, then read output with StreamReader (internal class)
			String cmd = "reg query " + '"' + location + "\" /v " + key;
			//IJ.log(""+cmd);
			Process process = Runtime.getRuntime().exec(cmd);

			StreamReader reader = new StreamReader(process.getInputStream());
			reader.start();
			process.waitFor();
			reader.join();
			String output = reader.getResult();
			//IJ.log(""+output);
			return output;	

			// Output has the following format:
			// \n<Version information>\n\n<key>\t<registry type>\t<value>
			//if( !output.contains("\t")){
			//        return "WinReg Error: string does not contain tabs :-(";
			//}

			// Parse out the value
			//String[] parsed = output.split("\t");
			//return parsed[parsed.length-1];
		}
		catch (Exception e) {
			return "WinReg Error: something unknown went wrong :-(";
		}

	}

	public static String getTrimmedRegistryValue(String winreglocation, String winregkey, String winregseparator) {
		//IJ.log("reading from "+winreg_location);
		String temp1 = WindowsRegistry.readRegistry(winreglocation, winregkey);
		//IJ.log("return="+temp1);
		String [] temp2 = temp1.split(winregseparator); // extract only the value
		String value = temp2[1].trim(); // get rid of whitespaces
		return value;
	}
	
	static class StreamReader extends Thread {
		private InputStream is;
		private StringWriter sw= new StringWriter();

		public StreamReader(InputStream is) {
			this.is = is;
		}

		public void run() {
			try {
				int c;
				while ((c = is.read()) != -1)
					sw.write(c);
			}
			catch (IOException e) { 
			}
		}

		public String getResult() {
			return sw.toString();
		}
	}

	public static void checkImageJ(){
		IJ.log("You successfully imported the WindowsRegistry java class to ImageJ.");
	}

	public static void main(String[] args) {

		// Sample usage
		IJ.log("read: "+WindowsRegistry.readRegistry("HKLM\\SOFTWARE\\MyCo","Data"));
		WindowsRegistry.writeRegistry("HKLM\\SOFTWARE\\MyCo","Data","suupi");
		IJ.log("read: "+WindowsRegistry.readRegistry("HKLM\\SOFTWARE\\MyCo","Data"));

	}
}