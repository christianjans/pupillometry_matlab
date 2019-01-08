function R = doFit(v, pupilSize, seedPoints, sThres, params, mask)
% circular+elliptical fit algorithm for the input video

fitMethod = params.fitMethod;
doPlot = params.doPlot;
thresVal = params.thresVal;
frameInterval = params.frameInterval;
skipBadFrames = params.skipBadFrames;

% Preallocate some variables
sFormer = [];
n = 0;

% Initialize axes if necessary
if doPlot
    hFigVid = figure;
    axRad = axes('Parent', hFigVid);
    plotExist = false;
end

% Find smallest radius
rmin = floor(pupilSize*0.4);
if rmin <10
    rmin = 10;
end
rmax = rmin*3;

% Set start frame
v.CurrentTime = params.startFrame/v.FrameRate;

while hasFrame(v)
    message = sprintf(['\n\nProcessing ',v.name]);
    utils.progbar(v.CurrentTime/v.Duration,'msg',message);
    F=rgb2gray(readFrame(v));
    
    if params.doCrop
        xDim = any(mask, 1);
        yDim = any(mask, 2);
        rectDims = [sum(yDim), sum(xDim)];
        F = reshape(F(mask), rectDims);
    end
    
    frameNum = round(v.CurrentTime * v.FrameRate);

    % Skip unused frames, if necessary
    for iSkip = 1:frameInterval-1
        if hasFrame(v)
            readFrame(v);
        else
            break
        end
    end

    % adjust contrast
    if params.enhanceContrast
        F = imadjust(F);
    end

    F = medfilt2(F);
    if pupilSize < 20
        F = imresize(F, 2);
    end

    if n == 0
        aveGVold = mean(mean(F));
    end

    n=n+1;

    % select one of the input seed points which is located inside the black
    % part of the pupil
    [s,sFormer,seedPoints,sThres,aveGVold] = checkSeedPoints(F,seedPoints,...
        sThres,sFormer,aveGVold, skipBadFrames);
    if isempty(s)
        R(n,:)=[frameNum,NaN];
        continue
    end

    % Use regionGrowing to segment the pupil P is the detected pupil
    % boundary, and FI is a binary image of the pupil
    [~, FI] = regionGrowing(F,s,thresVal);

    % Find the origin and radius of the pupil
    [~, r] = imfindcircles(FI, [rmin, rmax],'ObjectPolarity','bright');

    % Try double rmax, if nothing identified
    if isempty(r)
        rmax = 2*rmax;
        [~, r] = imfindcircles(FI, [rmin, rmax], 'ObjectPolarity', ...
            'bright');
    end

    % Cases where imfindcircles didn't identify any circle
    if isempty(r) && n == 1
        error('pupilMeasurement:doFit:NoCircle', ['No circular ', ...
            'structure for radius %0.3f in this frame'], rmax);
    end

    % If there are more than 1 fitted circle, use elliptical fit, or if
    % there is only one fitted circle, but its radius has big difference
    % from the radius in the former frame, use elliptical fit
    if frameInterval <=10
        Rdiff = rmin*0.3;
    elseif frameInterval <= 20
        Rdiff = rmin*0.5;
    elseif 20 < frameInterval
        Rdiff = rmin*0.7;
    end

    nCircle = length(r);
    isBigOrNone = isempty(r) || (n==1 && any(abs(r-pupilSize/2)>(rmin*0.5))); % first frame
    isBigOrNone = isBigOrNone || (n>1 && any(abs(r-R(n-1))>(Rdiff))); % subsequent frames

    if (nCircle ~= 1 ||  isBigOrNone) && fitMethod ~= 1
        
        p=regionprops(FI,'MajorAxisLength');
        a = p.MajorAxisLength/2;
        R(n,:)=[frameNum,a];
        rmin = floor(a*0.9);
        rmax = ceil(a*1.1);

    else % circular fit
        if nCircle > 1
            warning('Multiple circles fitted, using first');
        end

        R(n,:)=[frameNum,r(1)];
        rmin = floor(r(1)*0.9);
        rmax = ceil(r(1)*1.1);
    end

    % plot the variation of the pupil radius
    if doPlot && ~plotExist
        plotExist = true;
        plot(axRad, R(:,1),R(:,2))
        drawnow
        title('Pupil Radius');
        xlabel('frame number');
        ylabel('Pupil Radius/pixel');
        
    elseif doPlot && plotExist
        plot(axRad, R(:,1),R(:,2)) % change the line data
        drawnow
    end
end
