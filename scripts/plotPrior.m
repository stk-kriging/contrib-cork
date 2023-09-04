clf; close all; clear;

mode = 1;
sigma = 3;
mu=sigma^2+log(mode);
pd = makedist('Lognormal','mu',mu,'sigma',sigma)

betaz = exp(linspace(log(1e-4),log(1e4))); % alpha
pdfz = zeros(size(betaz));
for  i = 1:length(betaz)
    pdfz(i)=pdf(pd,betaz(i));
end
export_csv('results/PriorPDFlog.csv', [betaz', pdfz'], 'beta, pdf');
figure(1)
subplot(1,2,1)
semilogx(betaz, pdfz)
xlabel('2\alpha')

betaz = linspace(1e-4, 3);
pdfz = zeros(size(betaz));
for  i = 1:length(betaz)
    pdfz(i)=pdf(pd,betaz(i));
end
export_csv('results/PriorPDF.csv', [betaz', pdfz'], 'beta, pdf');
figure(1)
subplot(1,2,2)
plot(betaz, pdfz)
xlabel('2\alpha')
