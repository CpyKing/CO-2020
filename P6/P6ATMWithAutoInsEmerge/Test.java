import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Scanner;

  
public class Test {  
	private static String xilinx = "C:\\Xilinx\\14.7\\ISE_DS\\ISE";
	private static String time = "5us";
	private static String selasmName = "test.asm";
	private static String mainModuleName = "mips";
	private static String testBanchName = "mips_tb";
	private static String[] tipsOfInput = {"Input the standard MIPS .asm :",
										   "Please input the absolute ISE\\bin path :",
										   "Please input the top module name (exclude .v) :",
										   "Please input name of testbanch (exclude .v) :",
										   "Choose default selection or NOT ?",
										   "Test on going..."};
	private static Scanner in = new Scanner(System.in);
	private static int isRight = 0;
	
	public static int check(String asmName) {
		//import data
		System.out.println(tipsOfInput[5]);
//    	System.out.print(tipsOfInput[4]);
//    	if((in.next()).charAt(0) == '0')
//    	{
//	    	System.out.print(tipsOfInput[0]);
//	    	asmName = in.next();
//	    	System.out.print(tipsOfInput[1]);
//	    	xilinx = in.next();
//	    	System.out.print(tipsOfInput[2]);
//	    	mainModuleName = in.next();
//	    	System.out.print(tipsOfInput[3]);
//	    	testBanchName = in.next();
//    	}
    	//
    	String path = System.getProperty("user.dir");
    	String fileWrite = "", fileExtensionName = "";
    	System.setProperty("user.dir", path);
    	/////////////////////////////   ////////////////////////
    	File file = new File(path);
    	File[] fileList = file.listFiles();
    	FileOutputStream fos = null;
    	OutputStreamWriter writer = null;
    	try {
    		fos = new FileOutputStream(new File(mainModuleName + ".prj"));
    		writer = new OutputStreamWriter(fos);
    	}catch (Exception e) {
    		e.printStackTrace();
    	}
    	
    	for(File f : fileList)
    	{
    		fileExtensionName = getExtensionName(f.getName());
    		if(fileExtensionName != null && fileExtensionName.equals("v"))
    		{
    			fileWrite = "verilog work \""+path+"\\"+f.getName()+"\"\n";
    			try {
    				writer.append(fileWrite);
    			}catch (Exception e) {
    				e.printStackTrace();
    			}
    		}
    	}
    	
    	try {
			writer.close();
		} catch (IOException e1) {
			e1.printStackTrace();
		}
    	
    	try {
    		fos = new FileOutputStream(new File(mainModuleName + ".tcl"));
    		writer = new OutputStreamWriter(fos);
    		fileWrite = "run "+time+";\nexit;\n";
    		writer.append(fileWrite);
    		writer.close();
    	}catch (Exception e) {
    		e.printStackTrace();
    	}
    	//////////////////////////        /////////////////////////
    	/////////////////////////          /////////////////////////
    	try {
    		fos = new FileOutputStream(new File("TestMachineEnter.bat"));
    		writer = new OutputStreamWriter(fos);
    		fileWrite = "@echo off\n" + 
    					"java -jar Mars.jar db nc mc CompactDataAtZero dump .text HexText code.txt >ans.txt " + asmName + "\n" +
    					xilinx + "\\bin\\nt64\\fuse --nodebug  --prj " + mainModuleName + ".prj -o " + mainModuleName + ".exe " + testBanchName + "\n" +
    					mainModuleName + ".exe -nolog -tclbatch " + mainModuleName +".tcl >my.txt\n";
    		writer.append(fileWrite);
    		writer.close();
    	}catch (Exception e) {
    		e.printStackTrace();
    	}
    	/////////////////////////           /////////////////////////
    	/////////////////////////            ////////////////////////
        Runtime run = Runtime.getRuntime();
        try { 
        	// gen test.asm
        	Process p = run.exec("gen");
        	Thread.currentThread();
			Thread.sleep(300);
			//
        	p = run.exec("cmd /c TestMachineEnter.bat");
			Thread.sleep(15000);
			System.out.println("\nISIM Completed!");
			handleData();
			Thread.sleep(700);
        } catch (IOException e2) {
        	e2.printStackTrace();
        } catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return isRight;
	}
	
	public static int handleData() throws IOException {
    	FileInputStream fisMars = new FileInputStream("ans.txt");
    	InputStreamReader inReaderMars = new InputStreamReader(fisMars);
    	BufferedReader marsReader = new BufferedReader(inReaderMars);
    	FileInputStream fisVerilog = new FileInputStream("my.txt");
    	InputStreamReader inReaderVerilog = new InputStreamReader(fisVerilog);
    	BufferedReader verilogReader = new BufferedReader(inReaderVerilog);
    	
    	String strMars = null, strVerilog = null;
    	strVerilog = verilogReader.readLine();
    	while(strVerilog != null && strVerilog.charAt(0) != ' ')
    		strVerilog = verilogReader.readLine();
    	strMars = marsReader.readLine();
    	strVerilog = strVerilog.substring(20);
    	while(strMars != null && strVerilog != null && strMars.length() > 1 && strVerilog.length() > 1)
    	{
    		if(strMars.length()>=11 && strMars.charAt(12) == ' ' && strMars.charAt(13) == '0')
    		{
    			strMars = marsReader.readLine();
    			continue;
    		}
    		if(strMars.equals(strVerilog) == false)
    		{
    			System.out.println("Failed to match\n" + "Ans at: " + strMars + "\nYours at: " + strVerilog);
    			isRight = 0;
    			return isRight;
    		}
    		strVerilog = verilogReader.readLine();
    		if(strVerilog != null)strVerilog = strVerilog.substring(20);
    		strMars = marsReader.readLine();
    	}
    	if(strMars == null)
    		strMars = "";
    	if(strVerilog == null)
    		strVerilog = "";
    	if(strMars.equals(strVerilog)) {
    		System.out.println("MATCH sucessfully!\n");
    		isRight = 1;
    	}
    	else {
    		System.out.println("Failed to match.\nNot the same lenth");
    		isRight = 0;
    	}
    	return isRight;
    }
     
	public static String getExtensionName(String fileName) {
		int dotIndex = fileName.lastIndexOf(".");
		
		if(dotIndex < 0 || dotIndex == fileName.length() - 1)
			return null;
		return fileName.substring(dotIndex + 1, fileName.length());
	}
	
	public static void main(String[] args) { 
		String path = System.getProperty("user.dir");
		String fileExtensionName = "";
		File file = new File(path);
		File[] fileList = file.listFiles();
//		for(File f : fileList)
//		{
//			fileExtensionName = getExtensionName(f.getName());
   //		if(fileExtensionName != null && fileExtensionName.equals("asm"))
   //		{
   //			selasmName = f.getName();
      // 		System.out.println(selasmName);
       //		check(selasmName);
       //		if(isRight == 0)
       //		{
       //			System.out.println("WRONG!");
       //			break;
       //		}
   	//	}
	//	}
		 int cnt = 1;
		 int cntWrong = 0;
		 ArrayList<String> WrongList = new ArrayList<String>();
		 for( ; cnt < 5; cnt++)
		 {
		 	System.out.println("testpoint"+cnt);
		 	check("test.asm");
		 	if(isRight == 0)
         	{
         		System.out.println("WRONG!");
         		WrongList.add("testpoint"+cnt);
         		//break;
         	}
		 }
		 for(String s : WrongList)
		 {
			 System.out.println(s);
		 }
    }
    
}


