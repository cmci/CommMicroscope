/* Determine colony size and give back imaging positions
 * Pierre Neveu
 */
//filepath = "D:\\Antonio\\Pierre130410\\AFImg_W001_P001_T003.lsm";
filepath=getArgument();

if (endsWith(filepath,"lsm") && indexOf(filepath, "AFImg" ) > 0 ) {
	open(filepath);
	// Get scaling factors for x, y and z

	run("Set Measurements...","area mean centroid center bounding fit redirect=None decimal=6");
	if (bitDepth()==8 || bitDepth()==16) {
		upperThreshold=pow(2,bitDepth())*0.9;}
	else {upperThreshold=100000;}
	//this is not used
	scale=newArray(3);
	getVoxelSize(scale[0], scale[1], scale[2],unit);


	id=getImageID;
	getDimensions(nWidth,nHeight,nChannels, n, nZ);
	print(nZ);
	run("Set Scale...","distance=1 known=1 pixel=1 unit=pixel");
	run("Median...", "radius=1 stack");
	run("Make Binary", "method=Default background=Default calculate black");
	run("Dilate", "iterations=7 stack");
	run("Fill Holes","stack");
	run("Erode", "iterations=7 stack");
	run("Open", "iterations=7 stack");
	run("Select All");
	getVoxelSize(voxelX, voxelY, voxelZ, unit);

	meanIntensities=newArray(n*nChannels);
	stdIntensities=newArray(n*nChannels);
	x=newArray(n);

	for (i=0; i<n; i++) {
		x[i]=i;
		for (k=0; k<nChannels; k++){
	          selectImage(id);
	          setSlice((nChannels*i+k)+1);
			   getRawStatistics(a, meanIntensities[i+n*k],a,a, stdIntensities[i+n*k],aa);
	          if (meanIntensities[i+n*k]>upperThreshold){meanIntensities[i+n*k]=0;}  
	      }
	}

	//find brightest channel
	brightestChannel=0;
	maxStd=newArray(nChannels);
	if (nChannels>1) {
		for (i=0; i<nChannels; i++){
			temparray=Array.slice(stdIntensities,i*n,(i+1)*n);
			Array.getStatistics(temparray, mm, maxStd[i],mm,mm);
		}
		aaa=Array.rankPositions(maxStd);
		for (i=0; i<nChannels; i++){
			if (aaa[i]==nChannels-1){brightestChannel=i;}
		}	
	}

	//find center of colony
	mmean=Array.slice(meanIntensities,brightestChannel*n,(brightestChannel+1)*n);
	Fit.doFit("Gamma Variate",x, mmean);
	colonymiddle=round(Fit.p(0)+Fit.p(2)*Fit.p(3));
	print(colonymiddle);
	if (colonymiddle>n/2){ zstop=n; }
		else {zstop = 2*colonymiddle;}
	run("Clear Results");

	//find region to image
	selectImage(id);
	setSlice( maxOf(minOf(colonymiddle, n ),1));
	run("Analyze Particles...", "size=25-Infinity circularity=0.00-1.00 show=Outlines display");
	xMin=nWidth-1;
	xMax=0;
	yMin=nHeight-1;
	yMax=0;
	for (i=0;i<nResults; i++){
		bx1=getResult("BX",i);
		by1=getResult("BY",i);
		bx2=bx1+getResult("Width",i);
		by2=by1+getResult("Height",i);
		xMin=minOf(xMin,bx1);
		yMin=minOf(yMin,by1);
		xMax=maxOf(xMax,bx2);
		yMax=maxOf(yMax,by2);
	
	}

	// give coordinates with respect to middle. 0,0,0 is no change in positio
	offsetX = maxOf(floor((xMin+xMax)/2),0) - nWidth/2;
	offsetY = maxOf(floor((yMin+yMax)/2),0) - nHeight/2;
	offsetZ = colonymiddle - n/2;
	deltaX = minOf(xMax-xMin+20,nWidth-1-xMin);
	deltaY = minOf(yMax-yMin+20,nHeight-1-xMin);
	deltaZ = zstop;
	
	textfile=replace(filepath,".lsm","_positions.txt");
	f=File.open(textfile);
	print(f,"offsetX = "+offsetX);
	print(f,"offsetY = "+offsetY);
	print(f,"offsetZ = "+offsetZ);
	print(f,"DeltaX = "+deltaX);
	print(f,"DeltaY = "+deltaY);
	print(f,"DeltaZ = "+deltaZ);
	File.close(f);
	
	
	 if ( unit == "µm" ) {
	 	unit = "um";
	 }
	 
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=unit value=["+ unit +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=offsetx value=["+ offsetX +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=offsety value=["+ offsetY +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=offsetz value=["+ offsetZ +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=DeltaZ value=["+ deltaZ +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=fileAnalyzed value=["+ filepath +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro] key=Code value=[6] windows=REG_SZ");
	run("Close All");
}


