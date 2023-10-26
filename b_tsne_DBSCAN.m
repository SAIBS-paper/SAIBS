loading = false;
saving = true;

if loading
    disp('loading')
    x_data = load('data194.mat');
    raw_data = x_data.data;
    data = zeros(size(raw_data));
    for i=1:length(data)
        data(i,:) = rescale(raw_data(i,:));
    end
    disp('tsne')
    raw_x_tsne = tsne(data,'NumDimensions',2);
end

disp('dbscan')
cluster = dbscan(raw_x_tsne,3,30);
x_tsne = raw_x_tsne;
if saving
    data = raw_data(cluster~=-1,:);
    x_tsne = x_tsne(cluster~=-1,:);
    cluster(cluster==-1) = [];
    save('checkx.mat','data','-v7.3')
    save('checkt.mat','cluster')
end

figure
clusters = length(categories(categorical(cluster)));
gscatter(x_tsne(:,1),x_tsne(:,2),cluster, colormap(turbo(clusters)));
legend(char((1:clusters).'+96));
drawnow
