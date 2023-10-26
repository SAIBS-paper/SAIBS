x = load('checkx.mat');
t = load('checkt.mat');

x = x.data.';
t = t.cluster.';
t = full(ind2vec(t));
min_AIC = Inf;

for k=12:16
    cannet = train(patternnet(k),x,t);
    predict = sim(cannet,x);
    n = length(t);
    AIC = n * log(sse(cannet,t,predict)/n) + 2 * length(getwb(cannet));
    
    if min_AIC > AIC
        net = cannet;
        fprintf('clusters = %d, AIC = %d\n',k,AIC)
        min_AIC = AIC;
        %input('><')
    end
    
end
save('CNN194.mat', 'net')
disp('complete')