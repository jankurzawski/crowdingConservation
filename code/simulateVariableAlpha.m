clear

t = readtable('surface_area_data.csv');

num_subjects = size(t, 1);

v4_area = (...
        t.V4_R1_lh + ...
        t.V4_R2_lh + ...
        t.V4_R1_rh + ...
        t.V4_R2_rh...
    ) /2;

lambda0 = t.NLetters;

mn.A = mean(v4_area);
mn.L = mean(lambda0);

sd.A = std(v4_area);
sd.L = std(lambda0);

clear v4_area lambda0;

Bouma2lambda = @(Bouma) 2*pi*2.1*(log(128/3)-125/128)./Bouma.^2 ;

lambda2Bouma = @(lambda, alpha) sqrt(2*pi*alpha*(log(128/3)-125/128)./lambda);

fprintf('\n');

% one iteration for each noise level
for jj = 10:-1:1

    % correlation between lambda and V4
    r.pop(jj) = jj/10;


    % covariance between lambda and V4
    cv = sd.A * sd.L * r.pop(jj); 
    
    % covariance matrix to simluate the two vectors
    Sigma = [sd.A.^2 cv; cv sd.L.^2];
    
    fprintf('.');
 
    for ii = 10000:-1:1        

        % simluate them!
        x = mvnrnd([mn.A mn.L], Sigma, num_subjects);
        v4 = x(:,1);
        lambda = x(:,2);

        alpha = randn([num_subjects,1])*0.38+2.10;        
          
        Bouma = lambda2Bouma(lambda, alpha); 

        lambda_inferred = Bouma2lambda(Bouma);

        r_sample(ii)    = corr(lambda, v4); % ground truth
        r_inferred(ii)  = corr(lambda_inferred, v4); % expected value assuming fixed lambda
        r_sample_v_inferred(ii)  = corr(lambda_inferred, lambda);
        
        c_inferred(ii) = sqrt(lambda_inferred \ v4);
        c(ii) = sqrt(lambda \ v4);
    end
    
    r.sample(jj)    = mean(r_sample);
    r.inferred(jj)  = mean(r_inferred);
    r.sample_v_inferred(jj) = mean(r_sample_v_inferred);
end

figure(1),set(gcf, 'Color', 'w')
clf; 
plot(...
    r.pop, r.sample, '-o', ...
    r.pop, r.inferred, '-o', ...
    r.pop, r.sample_v_inferred, '-o', ...
    r.pop, r.inferred./mean(r.sample_v_inferred), 'xk--', ...
    'LineWidth', 2, 'MarkerSize',10); 

axis([0 1 0 1]); axis square
set(gca, 'FontSize', 16)
xlabel('\lambda vs V4 (correlation)')
ylabel('Correlation coefficient')
l = legend(...
    '\lambda vs V4, ground truth',...
    '\lambda vs v4, inferred (assume constant \alpha)', ...
    '\lambda, ground truth vs inferred', ...
     'lambda vs v4, inferred + noise correction', ...
    'Location','best', 'Box', 'off');
box off;
fprintf('\n');
