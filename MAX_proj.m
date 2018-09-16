function [max_proj]= MAX_proj(A,StartF,EndF,StartZ,EndZ,Channel)
    max_proj = double(zeros(size(A,1), size(A,2),EndF-StartF));
    for f = [StartF:EndF]'
        max_proj(:,:,f) = max(A(:,:,Channel,StartZ:EndZ,f),[],4);
        %max_proj(:,:,:,f) = max(A(:,:,:,:,f),[],4); %to do projection of both channels
        %for Row = 1:size(A,1)
         %   for Column = 1:size(A,2)
          %      Values = A(Row,Column,Channel,Start:End,f);
           %     max_proj(Row,Column,f) = max(Values);
           % end
       % end  
    end
    max_proj = max_proj(:,:,StartF:EndF);
end