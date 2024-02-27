%% plot the data

set(figure,'windowstyle','docked')
for i = 1:size(a,2)-1
    scatter(a(:,1),a(:,i+1))
    hold on
end

%%
% define the expected breaks

Breaks = { [4]} ;
nSets = size(Breaks,1) ;

%% find the optimized break
for w = 1:nSets
    [xData, sortIdx] = sort(a(:,1)) ;
    yData = a(sortIdx,w+1) ;
    xData(isnan(yData)) = [] ;
    yData(isnan(yData)) = [] ;
    
    breaks = Breaks{w} ;
    nBreaks = numel(breaks) ;
    datasets = cell(nBreaks+1,1) ;
    breaksIdx = nan(nBreaks+1,2) ;
    
    for i = 1:nBreaks+1
        if i==1
            isWithin = xData<breaks(i) ;
        elseif i==nBreaks+1
            isWithin = xData>=breaks(i-1) ;
        else
            isWithin = xData>=breaks(i-1) & xData<breaks(i) ;
        end
        idx = find(isWithin) ;
        breaksIdx(i,:) = [idx(1) idx(end)] ;
        datasets{i} = [xData(idx) yData(idx)] ;
    end
    
    % find the optimal point per set
    breakLocation = nan(nBreaks,1) ;
    
    for j = 1:nBreaks
        data = cell2mat(datasets(j:j+1)) ;
        
        nData = size(data,1) ;
        nSearches = nData-5 ;
        
        errorEst = nan(nSearches,1) ;
        
        for k = 1:nSearches
            idx1 = 1:k+2 ;
            idx2 = k+3:nData ;
            
            data1 = data(idx1,:) ;
            data2 = data(idx2,:) ; 
            
            [poly1,s1] = polyfit(data1(:,1),data1(:,2),1) ;
            [poly2,s2] = polyfit(data2(:,1),data2(:,2),1) ;
            
            est1 = polyval(poly1,data1(:,1)) ;
            est2 = polyval(poly2,data2(:,1)) ;
            
            errorEst(k) = sum(abs(data(:,2)-[est1;est2])) ;
        end
        
        [~,minLoc] = min(errorEst) ;
        breakLocation(j) = minLoc+breaksIdx(j,1)+2 ;
    end
    
    % plot the results
    idx2 = [1;breakLocation;size(xData,1)+1] ;
    
    for i = 1:nBreaks+1
        idx3 = idx2(i):idx2(i+1)-1 ;
        polyData = polyfit(xData(idx3),yData(idx3),1) ;
        evalData = polyval(polyData,xData(idx3)) ;
        plot(xData(idx3),evalData,'-')
    end
end
disp(['The break(s) is at ' num2str(xData(breakLocation)) ' GPa'])