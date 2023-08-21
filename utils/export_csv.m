function export_csv(filename, data, header)
%EXPORT_CSV Summary of this function goes here
%   Detailed explanation goes here
if nargin ==3
    if iscell(header)
        headertext=header{1};
        for i = 2:length(header)
            headertext = [headertext ',' header{i}];
        end
    else
        headertext=header;
    end
    fid = fopen(filename,'w'); 
    fprintf(fid,'%s\n',headertext);
    fclose(fid); 
end
%write data to end of file
dlmwrite(filename,data,'-append');
end

