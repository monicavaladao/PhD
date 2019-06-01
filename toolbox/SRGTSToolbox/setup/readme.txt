+-------------------------------------------------------------------------+
| SURROGATES Toolbox                                                      |
| Working at full speed!!!                                                |
+-------------------------------------------------------------------------+

The SURROGATES Toolbox is a general-purpose library of multidimensional
function approximation and optimization methods for MATLAB and OCTAVE.

+-------------------------------------------------------------------------+
| INSTALLATION
+-------------------------------------------------------------------------+
Download the latest version from http://sites.google.com/site/felipeacviana

Unzip the file, open a MATLAB/OCTAVE terminal and go to the directory where
the toolbox is; for example:

C:\users\felipe\projects\SRGTSToolbox 
(there is no preference for where you will unzip it).

Next, type:

>> cd setup\
>> srgtsInstall

At this point, the setup routine will help you to install the
current version of the SURROGATES Toolbox.

The installation consists of:

A) Choosing between compiling or copying files for the GPML and SVM
   toolboxes (see details about third party software in section).
   The GPML gpml_sq_dist function computes a matrix of all pairwise squared
   distances between two sets of vectors.
   There are C and M versions of this function.
   When installing the \SRGTStoolbox, you can choose between
     1) copying a pre-compiled file (I have tested it with MATLAB 7.0 and
        OCTAVE 3.2.4), or
     2) compiling the code for your machine (preferable, but may require
        you to chose a compiler --- this is the default option), or
     3) copying the MATLAB/OCTAVE version of this function.

   The compiled versions are potentially faster than the MATLAB/OCTAVE one.

B) The SVM svmgunn_qp function is a quadratic and linear programming
   optimizer. Unfortunately, I have succeeded compiling it only for MATLAB
   (that is why SVM is not available in OCTAVE).
   When installing the SURROGATES Toolbox, you can choose between
     1) copying a pre-compiled file (I have tested it with MATLAB 7.0 and
        OCTAVE 3.2.4), or
     2) compiling the code for your machine (preferable, but may require
        you to chose a compiler --- this is the default option).

+-------------------------------------------------------------------------+
| UNINSTALLATION
+-------------------------------------------------------------------------+
Open a MATLAB/OCTAVE terminal and go to the directory where the toolbox
is. For example:

C:\users\felipe\projects\SRGTSToolbox 

Next, type:

>> cd setup\
>> srgtsUninstall

At this moment, the setup routine will help you to uninstall the
current version of the SURROGATES Toolbox.

+-------------------------------------------------------------------------+
| OBSERVATION
+-------------------------------------------------------------------------+

The current version of the SURROGATES Toolbox was developed using
    - MATLAB Version 7.6.0 (R2008a) under Windows XP.
    - OCTAVE Version 3.2.4 under Ubuntu 11.04.

To check the current version of the SURROGATES Toolbox, open a
MATLAB/OCTAVE terminal and type:

>> srgtsVersion
