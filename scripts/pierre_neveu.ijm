/* Determine colony size and give back imaging positions
 * Pierre Neveu
 */



//filelist=getArgument();
run("Clear Results");
run("Set Measurements...","area mean centroid center bounding fit redirect=None decimal=6");
volumedir="/Users/neveu/projects/tischi/516_1/";
//volumedir="/Users/neveu/projects/tischi/highres_moreZ/";

// keep only lsm files
allfilelist=getFileList(volumedir);
alllsmfiles="";
for (j=0; j<lengthOf(allfilelist); j++){
	if (endsWith(allfilelist[j],".lsm")) {
		alllsmfiles=alllsmfiles+","+allfilelist[j];
		}
}
filelist=split(alllsmfiles,",");

for (j=0; j<lengthOf(filelist); j++){
run("Clear Results");
open(volumedir+filelist[j]);

// Get scaling factors for x, y and z
imageinfo=getImageInfo();
allinfo=split(imageinfo,"\n");
scale=newArray(3);
if (bitDepth()==8 || bitDepth()==16) {
	upperThreshold=pow(2,bitDepth())*0.9;}
	else {upperThreshold=100000;}
for (i=0; i<lengthOf(allinfo); i++) {
	if (startsWith(allinfo[i],"Voxel_size_X")) {
		aaa=split(allinfo[i]," ");
		scale[0]=aaa[1];}
	else  if (startsWith(allinfo[i],"Voxel_size_Y")) {
		aaa=split(allinfo[i]," ");
		scale[1]=aaa[1];} 
	else  if (startsWith(allinfo[i],"Voxel_size_Z")) {
		aaa=split(allinfo[i]," ");
		scale[2]=aaa[1];} 
}

id=getImageID;
getDimensions(nWidth,nHeight,nChannels,n,nZ);
run("Set Scale...","distance=1 known=1 pixel=1 unit=pixel");
run("Median...", "radius=1 stack");
run("Make Binary", "method=Default background=Default calculate black");
run("Dilate", "iterations=7 stack");
run("Fill Holes","stack");
run("Erode", "iterations=7 stack");
run("Open", "iterations=7 stack");
run("Select All");

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
if (colonymiddle>n/2){zstop=n;}
	else {zstop=2*colonymiddle;}
run("Clear Results");

//find region to image
selectImage(id);
setSlice(minOf(colonymiddle,n));
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


//write parameters in textfile
textfile=volumedir+replace(filelist[j],".lsm",".txt");
f=File.open(textfile);
print(f,"Z = "+colonymiddle);
print(f,"DeltaZ = "+zstop);
print(f,"X = "+maxOf(floor((xMin+xMax)/2),0));
print(f,"DeltaX = "+minOf(xMax-xMin+20,nHeight-1-xMin));
print(f,"Y = "+maxOf(floor((yMin+yMax)/2),0));
print(f,"DeltaY = "+minOf(yMax-yMin+20,nHeight-1-xMin));

File.close(f);
selectWindow("Drawing of "+filelist[j]);
close;
selectWindow(filelist[j]);
close();
}
