classdef SaliencySorter < matlab.System
    
    properties
    end
    
    properties(Access=public)
        saliencyParameters;
        method;
    end
    
    methods
        function obj = SaliencySorter(parameters)
            addpath('Saliency/basic');
            obj.saliencyParameters = parameters;
            obj.method = parameters.method;
        end
        
        function sortedList = sort(self,event)
            for i = 1 : numel(event)
                % Compute Saliency Map
                if strcmp(self.method,'basic')
                    image = event(i).getImage;
                    smap = signatureSal(image, self.saliencyParameters);
                    if (self.saliencyParameters.gauss)
                        smap= smap .* Gaussian_filter(size(smap),self.saliencyParameters.sigma);
                    end
                elseif strcmp(self.method,'deep')
                    T=load([self.saliencyParameters.deepPath sprintf('%06g',  event(i).index) '.mat']);
                    smap = zeros(size(T.isal,3), size(T.isal,4));
                    if (self.saliencyParameters.gauss)
                        smap= smap .* Gaussian_filter(size(smap),self.saliencyParameters.sigma);
                    end
                    for ii = 1 : size(T.isal,3), for jj=1:size(T.isal,4) , smap(i,jj)=T.isal(1,1,ii,jj); end, end
                else
                    error('Saliency method incorrect');
                end
                
                % Obtain image weight
                event(i).weight = sum(sum(smap))/(size(smap,1)*size(smap,2));
                % Plot
                %                 event(i).setAux(insertText( uint8(smap*255),[1,1], sprintf('%g',  event(i).weight)));
                event(i).setAux(writeOnImageHandler(uint8(smap*255), 'rectangle', [], '',  1/4, [10,10], sprintf('%g',  event(i).weight) ));
                
            end
            % Sort images by weight
            [~,indexSortedList]=sort([event.weight], 'descend');
            sortedList = event(indexSortedList);
            
        end
        
    end
end