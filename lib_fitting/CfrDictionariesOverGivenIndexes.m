function CfrDictionariesOverGivenIndexes(A, B, inds, OPT_PAR_LongStruct, flagSlow) 
if nargin<4
    optiontitle = 0;
    flagSlow = 0;
else
    optiontitle = 1;
end
[M, ~] = size(A);
resolution = sqrt(M);

for k=1:numel(inds)
    n = inds(k);

    subplot(1,2,1); 
    imagesc(reshape(A(:,n),resolution,resolution)); set(gca, 'DataAspectRatio', [1 1 1]); colorbar; title(num2str(n))
    title(sprintf('elem = %d',n ))

    subplot(1,2,2); 
    imagesc(reshape(B(:,n),resolution,resolution)); set(gca, 'DataAspectRatio', [1 1 1]); colorbar; hold on
    
    if optiontitle
        if numel(OPT_PAR_LongStruct) == 1
            % CONSIDER REMOVING THIS IF, I WON'T NEED IT ANYMORE
            % anche se funzionava bene
            title(sprintf('R2 = %d', round(OPT_PAR_LongStruct.R2fit(n)) ))
            center_x = OPT_PAR_LongStruct.center_x(n, 1);
            center_y = resolution-OPT_PAR_LongStruct.center_y(n, 2);
        else
            title(sprintf('R2 = %d', round(OPT_PAR_LongStruct(n).R2fit) ))
            center_x = OPT_PAR_LongStruct(n).center_x;
            center_y = resolution - OPT_PAR_LongStruct(n).center_y;
        end
        plot(center_x, center_y, 'rx')
    end
    if flagSlow
        waitforbuttonpress; clf
    else
        drawnow; pause(0.5); clf
    end
end
