run("Close All");
        
minAreaDom = 1 // min Area domains in um2
minAreaNuc = 60 // min Area nucleus in um2
maxErodeNuc = 6; //repetition of erode operations on binary nucleus
imgpath = 'C:\\Users\\Antonio Politi\\Science\\Julia_Atto\\test2\\test_W003_P001_T001.lsm';
open(imgpath);
origImg = getTitle();
rename("img_orig");
//segment the nuclei
if ( Stack.isHyperStack ) {
        Stack.getDimensions(width, height, channels, slices, frames);
        run("Median...", "radius=1 stack"); // this removes the shot noise
        run("Z Project...", "start=1 stop="+ slices+ " projection=[Max Intensity]");
        Stack.setChannel(3);
        run("Delete Slice", "delete=channel");
        rename("img_maxProj");    
        run("Hyperstack to Stack");   
}
else { 
        getDimensions(width, height, channels, slices, frames);
        run("Median...", "radius=1 stack"); // this removes the shot noise
        run("Z Project...", "start=1 stop="+ slices+ " projection=[Max Intensity]");
        getStatistics(area, mean, min, max);
        setMinAndMax(min, max);
        rename("img_maxProj");  
}
selectWindow("img_maxProj");

nrSlice = getSliceNumber();
for (i=1; i<nrSlice+1; i++){
	selectWindow("img_maxProj");
	setSlice(i);
	run("Duplicate...", "title=C"+i);
	getStatistics(area, mean, min, max);
	setMinAndMax(min, max);
	run("8-bit");
	if ( i == 1 ) {
		getStatistics(area, mean, min, max);
		setMinAndMax(min, max*2);
	}
	if ( i == 2 ) {
		getStatistics(area, mean, min, max);
		setMinAndMax(min, max/1.1);
	}
}
//create a merge figure 
run("Merge Channels...", " c6=C2 c2=C1 Composite keep");
run("RGB Color");
rename("nucleiDomComp");
//run("Enhance Contrast", "saturated=0.35"); 
findNuclei("C1", "nucleiBin", minAreaNuc, 2, maxErodeNuc);
if ( nrSlice > 1 ) { //detect als domains
	findDomains("C2", "domainsBin", minAreaDom);
	run("Clear Results");
	imageCalculator("Multiply create", "nucleiBin" , "domainsBin" );
	rename("nucleiSelBin");
	run("8-bit");
	run("Analyze Particles...", "size="+minAreaDom+"-Infinity circularity=0-1.00 show=[Masks] display include  in_situ");
	n = roiManager("count");
	toDelete = newArray(0);
	setOption("ExpandableArrays", true);
	for (i=0; i<n; i++) {
	      roiManager("select", i);
	      getStatistics(area, mean);
	      if (mean <= minAreaDom) {
	      	 	toDelete = append(toDelete, i);
      		}
	}
	roiManager("select", toDelete);
	roiManager("Delete");
	roiManager("Show None");
	roiManager("Show All");
	run("Add Image...", "image=nucleiDomComp x=0 y=0 opacity=100");
	run("Enhance Contrast", "saturated=0.35"); 
}





function findNuclei(imgName, imgNameout, minArea, medFilt, maxErode) {
	selectWindow(imgName);
	run("Duplicate...", "title="+imgNameout);
	run("Median...", "radius="+medFilt+" stack");
	//run("Gaussian Blur...", "sigma=2");
	//run("Find Edges");run("Auto Local Threshold", "method=Niblack radius=5 parameter_1=0 parameter_2=0 white");
	run("Find Edges");
	run("Auto Local Threshold", "method=Median radius=15 parameter_1=0 parameter_2=0 white");
	run("Fill Holes");
	run("Analyze Particles...", "size="+minAreaNuc+"-Infinity circularity=0.3-1.00 show=[Masks] display include clear include add in_situ");
	//TO AVOID particles at border of nucleus. Only particles in the middle are taken
	for (i=0; i< maxErode; i++) {
	        run("Erode");
	}
	run("Analyze Particles...", "size="+minArea+"-Infinity circularity=0.3-1.00 show=[Masks] display include clear include add in_situ");
}

function findDomains(imgName, imgNameout, minArea) {
	selectWindow(imgName);
	run("Duplicate...", "title="+imgNameout);
	run("Auto Local Threshold", "method=Median radius=15 parameter_1=0 parameter_2=0 white");
	//run("Fill Holes");
	run("Analyze Particles...", "size="+minArea+"-Infinity circularity=0-1.00 show=[Masks] display include  in_situ");
}

function append(arr, value) {
	arr2 = newArray(arr.length+1);
	for (i=0; i<arr.length; i++)
	arr2[i] = arr[i];
	arr2[arr.length] = value;
	return arr2;
}

//n = roiManager("count");
//multily values with rois
/*for (i=0; i<n; i++) {
      roiManager("select", i);
      run("Multiply...", "value=" + i+1);
 }*/

//run("Add Image...", "image=" + origImg +" x=0 y=0 opacity=100");

/*run("Auto Local Threshold", "method=Median radius=15 parameter_1=0 parameter_2=0 white");
run("Analyze Particles...", "size="+minAreaAtto+"-Infinity circularity=0-1.00 show=[Masks] display include  in_situ");
run("Duplicate...", "title=binaryRFP");
//run("Divide...", "value=255");