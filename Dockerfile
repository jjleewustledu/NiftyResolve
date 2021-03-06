# reference: https://hub.docker.com/u/jjleewustledu
FROM centos

LABEL maintainer="John J. Lee <www.github.com/jjleewustledu>"

# update CentOS; install base tools
# hostname, net-tools:  N.B. https://bugzilla.redhat.com/show_bug.cgi?id=1456583
# libgomp:  required by freesurfer mri_convert
# *libgfortran* required by 4dfp
RUN yum update -y && \
    yum -y install wget curl ca-certificates bzip2 unzip \
    compat-libgfortran-41 \
    emacs-nox \
    hostname \
    less \
    libgfortran \
    libgomp \
    pigz \
    pkg-config \
    rsync \
    tcsh \
    which

# setup Matlab Compiler Runtime
ARG MCR_REL=R2018b
ARG MCR_VER=95
ARG MCR_DEPS='qt5-qtbase qt5-qtbase-gui qt5-qtsvg qt5-qtwebkit qt5-qtwebsockets qt5-qtx11extras \
              libXcursor libXrandr libXt libXtst'
	      # atk ffmpeg-compat GConf2 gtk2 python34-libs libsndfile'      
RUN yum -y install ${MCR_DEPS}

# setup filesystem
RUN    mkdir /work && mkdir /ProjectsDir && mkdir /SubjectsDir && mkdir /export
ENV    WORK=/work
ENV    PROJECTS_DIR=/ProjectsDir
ENV    SUBJECTS_DIR=/SubjectsDir
ENV    EXPORT=/export
ENV    TMPDIR=/tmp
VOLUME $PROJECTS_DIR
VOLUME $SUBJECTS_DIR
VOLUME $EXPORT

# setup Matlab environment
ENV SHELL=/bin/bash
ENV MATLAB_SHELL=$SHELL
ENV MCR_ROOT=$EXPORT/matlab/MCR/${MCR_REL}/v${MCR_VER}
ENV PATH=$PATH:${MCR_ROOT}/bin
ENV XAPPLRESDIR=${MCR_ROOT}/v${MCR_VER}/X11/app-defaults
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${MCR_ROOT}/runtime/glnxa64:${MCR_ROOT}/bin/glnxa64:${MCR_ROOT}/sys/os/glnxa64:${MCR_ROOT}/sys/opengl/lib/glnxa64:${MCR_ROOT}/extern/bin/glnxa64
ENV MCR_CACHE_ROOT=$TMPDIR

# setup FSL
RUN  mkdir /fsl
COPY fsl /fsl
ENV  FSLDIR=/fsl
ENV  PATH=$FSLDIR/bin:$FSLDIR/etc/matlab:$PATH
ENV  FSLOUTPUTTYPE=NIFTI_GZ
ENV  FSLTCLSH=$FSLDIR/bin/fsltclsh
ENV  FSLWISH=$FSLDIR/bin/fslwish

# setup Freesurfer
RUN  mkdir /freesurfer
COPY freesurfer /freesurfer
ENV  FREESURFER_HOME=/freesurfer
ENV  OS=Linux
ENV  FS_OVERRIDE=0
ENV  NO_FSFAST=1
ENV  FSFAST_HOME=$FREESURFER_HOME/fsfast
ENV  FUNCTIONALS_DIR=$FREESURFER_HOME/sessions
ENV  MINC_BIN_DIR=$FREESURFER_HOME/mni/bin
ENV  MNI_DIR=$FREESURFER_HOME/mni
ENV  MINC_LIB_DIR=$FREESURFER_HOME/mni/lib
ENV  MNI_DATAPATH=$FREESURFER_HOME/mni/data
ENV  FSL_DIR=$FSLDIR
ENV  LOCAL_DIR=$FREESURFER_HOME/local
ENV  FSF_OUTPUT_FORMAT=nii.gz
ENV  MNI_PERL5LIB=$FREESURFER_HOME/mni/share/perl5
ENV  PERL5LIB=$MNI_PERL5LIB
ENV  PATH=$MINC_BIN_DIR:$FREESURFER_HOME/tktools:$FREESURFER_HOME/bin:$PATH
ENV  FIX_VERTEX_AREA=

# setup 4dfp
COPY lin64-tools $WORK/lin64-tools
COPY TRIO_Y_NDC $WORK/TRIO_Y_NDC
ENV  RELEASE=$WORK/lin64-tools
ENV  REFDIR=$WORK/TRIO_Y_NDC
ENV  REFDIR1=$REFDIR
ENV  PATH=$RELEASE:$PATH

# setup app
COPY ConstructResolvedApp/ConstructResolvedApp/for_testing/ConstructResolvedApp \
     $WORK/ConstructResolvedApp
COPY ConstructResolvedApp/ConstructResolvedApp/for_testing/run_ConstructResolvedApp.sh \
     $WORK/run_ConstructResolvedApp.sh
COPY ConstructResolvedApp/ConstructResolvedApp/for_testing/splash.png \
     $WORK/splash.png
COPY ConstructResolvedApp/ConstructResolvedApp/for_testing/requiredMCRProducts.txt \
     $WORK/requiredMCRProducts.txt
RUN  chmod a+x $WORK/ConstructResolvedApp
RUN  chmod a+x $WORK/run_ConstructResolvedApp.sh

# run_ConstructResolvedApp.sh
# requires args $MCR_ROOT subjects/sub-S12345/ses-E12345
WORKDIR    $PROJECTS_DIR
#ENTRYPOINT ["/work/run_ConstructResolvedApp.sh", "/export/matlab/MCR/R2018b/v95"]
#CMD [""]
CMD ["/bin/bash"]

# when ready:
# > docker push jjleewustledu/constructresolved-image:20190723
# > singularity pull docker://jjleewustledu/constructresolved-image:20190723

