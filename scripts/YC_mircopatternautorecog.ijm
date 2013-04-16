
'filepath = getArgument();
filepath = "C:\\Test\\incu90min_W001_P001_T001.lsm"

 if (endsWith(filepath,"lsm")) {
 	run("Close All");
 	run("Clear Results");
 	open(filepath);
 	getPixelSize(unit, pixelWidth, pixelHeight);
 	getDimensions(width, height, channels, slices, frames);
 	setBatchMode(true);
	roiManager("reset")
	run("Clear Results");

	image_name = getTitle();
	selectWindow(image_name);
	run("Split Channels");

        run("Clear Results");
        run("Set Measurements...", "mean redirect=None decimal=0");
        selectWindow("C3-"+image_name);
	run("Median...", "radius=2");
	run("Measure");
	mean_intensity=getResult("Mean", 0);
	run("Clear Results");
        //print(mean_intensity);

        setThreshold(mean_intensity, 255);
        setOption("BlackBackground", true);
        run("Convert to Mask");
        run("Fill Holes");
        run("Dilate");
        run("Erode");

	run("Analyze Particles...", "size=110-660 circularity=0-1.00 show=[Count Masks] display exclude include add in_situ");
	roiManager("Show All");
	selectWindow("C3-"+image_name);
        number_of_premary_area = roiManager("count");
        run("Clear Results");
        //print(number_of_premary_area);	

        selectWindow("C3-"+image_name);
	for(i=0; i<number_of_premary_area; i+=1){
	roiManager("Select", i);
	run("Convex Hull");
	run("Add...", "value=255");
	//roiManager("Select", i);
	//run("Subtract...", "value=i");
	}
	roiManager("Deselect");
	roiManager("Delete");
	roiManager("reset");
	setThreshold(255, 512);
        run("Convert to Mask");
        run("Divide...", "value=255");

	imageCalculator("Multiply create", "C1-"+image_name,"C3-"+image_name);
	
	selectWindow("Result of C1-"+image_name);
	run("Median...", "radius=2");
	setAutoThreshold("Li dark");
        getThreshold(lower1, upper1);
	setAutoThreshold("IJ_IsoData dark");
        getThreshold(lower2, upper2);
        lower = (lower1+lower2)/2;
        setThreshold(lower, 255);
        run("Convert to Mask");
        run("Fill Holes");
        run("Watershed");
	run("Analyze Particles...", "size=55-770 circularity=0.00-1.00 show=[Count Masks] display exclude include add in_situ");
        roiManager("Show None");
        roiManager("Deselect");
        roiManager("Delete");
        roiManager("reset");

        selectWindow("C3-"+image_name);
        roiManager("Show All");
        roiManager("Show None")
        run("Multiply...", "value=255");
        run("Make Binary");
        run("Analyze Particles...", "size=0-1000 circularity=0.00-1.00 show=Masks display exclude include add in_situ");
        roiManager("Show All");
        number_of_secondary_area = roiManager("count");
        //print(number_of_premary_area);
        //print(number_of_secondary_area);

        run("Set Measurements...", "  min integrated redirect=None decimal=3");
        for(i=0; i<number_of_secondary_area; i+=1){
        selectWindow("Result of C1-"+image_name);
	roiManager("Select", i);
	run("Duplicate...", "title=img");
	selectWindow("img");
	run("Clear Results");
	run("Measure");
	lower = getResult("Max",0);

	if(lower==0){
		selectWindow("C3-"+image_name);
		roiManager("Select", i);
		run("Subtract...", "value=255");
	}else{
		run("Duplicate...", "title=img2");
		selectWindow("img2");
		setThreshold(1,lower);
		run("Convert to Mask");
		run("Measure");
		close();
		selectWindow("img");
		setThreshold(lower, lower);
	        run("Convert to Mask");
                run("Measure");
                avarage1 = getResult("RawIntDen",1);
                avarage2 = getResult("RawIntDen",2);
                //print(i+":"+avarage1+":"+avarage2);
                if(avarage1>avarage2){
                	//print("a"+i);
                selectWindow("C3-"+image_name);
		roiManager("Select", i);
		run("Subtract...", "value=255");
                }
                if(avarage1>1000000){
                	//print("b"+i);
                selectWindow("C3-"+image_name);
		roiManager("Select", i);
		run("Subtract...", "value=255");
                }
                if(avarage1<330000){
                	//print("c"+i);
                selectWindow("C3-"+image_name);
		roiManager("Select", i);
		run("Subtract...", "value=255");
                }
	}
	selectWindow("img");
	close();
	}
	selectWindow("Result of C1-"+image_name);
	close();
       
        selectWindow("C3-"+image_name);
	run("Clear Results");
	roiManager("Deselect");
	roiManager("Delete");
	roiManager("reset");
	roiManager("Show All");
	run("Set Measurements...", "  centroid bounding redirect=None decimal=1");
        run("Analyze Particles...", "size=0-1000 circularity=0.00-1.00 show=Masks display exclude include add in_situ");
        roiManager("Show None");
        close();

        run("Merge Channels...", "c1=[C2-"+image_name+"] c2=[C1-"+image_name+"] create");
        run("Stack to RGB");
        selectWindow("Composite");
        setBatchMode(false);
        roiManager("Show All");
        roiManager("Select All");
        saveAs("tiff", File.getParent(filepath)+ "\\" +File.nameWithoutExtension + ".tif");

        //Write out positions to  folder
 	String.resetBuffer;

 	if ( unit == "µm" ) {
 		unit = "um";
 	}
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=unit value=["+ unit +"] windows=REG_SZ");

	String.resetBuffer;
	//nrPoints = nResults
	nrPoints = 1;
        for( i = 0; i< nrPoints-2; i++) {
        	out = getResult("X",i) - width*pixelWidth/2;
        	String.append(out + ", ");
        }
        out = getResult("X",nrPoints-1) - width*pixelWidth/2;
        String.append(out);
        run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=offsetx value=["+ String.buffer +"] windows=REG_SZ");
	String.resetBuffer;
        for( i = 0; i< nrPoints-2; i++) {
        	out = getResult("Y",i) - height*pixelHeight/2;
        	String.append(out + ", ");
        }
        out = getResult("Y",nrPoints-1) - height*pixelHeight/2;
        String.append(out);
        run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=offsety value=["+ String.buffer +"] windows=REG_SZ");
        run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=fileAnalyzed value=["+ filepath +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=Code value=[3] windows=REG_SZ");

}
