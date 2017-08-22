# Christian's method

from embl.almf import Microscope_Communicator
from ij import WindowManager

wm = WindowManager
#microscope = "LSM780"
microscope = "File system"
mc = Microscope_Communicator()
mc.setMicroscope(microscope)
mc.setFilepath('/Users/miura/Desktop/tmp/watch/p1_1.tif')
while True:
	mc.obtainImage(microscope)
	# check any hit
	
	if (WindowManager.getImageCount() > 0):
		#mc.image_selected_particle(int offsetx, int offsety)
		IJ.log("retrieved")
		break
	else:
		mc.do_nothing()
	