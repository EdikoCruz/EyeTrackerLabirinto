function main
%__________________________________________________________________________
% Este programa ira apresetar um ponto de fixacao e depois uma tela (imagem).
% Esta imagem contem um labirinto e sera apresentado por um tempo X.
% O objetivo e verificaf quantas sacadas a pessoa necessita para completar a 
% tarefa (ir de A ate B).
% Tambem sera analisado o tempo de resposta (ainda nao ha comando no programa
% para isto).
% Programa criado dia 04/12/12 por Bruno e Armindo.
% Alterado dia XX/YY/ZZ (foi feito isso e aquilo).
%__________________________________________________________________________

global CRS;             %Ativar a biblioteca de Cambridge
crsLoadConstants;       %Carrega as constantes pre-determinadas

%Verifica se estamos rodando o experimento no ViSaGe
CheckCard = crsGetSystemAttribute(CRS.DEVICECLASS);
if(CheckCard ~= 7)
error('Sorry, this demonstration requires a VSG ViSaGe.');
end;

%Seleciona a camera do videoEyeTracker (VET).
vetSetStimulusDevice(CRS.deVSG);
errorCode = vetSelectVideoSource(CRS.vsUserSelect);
if(errorCode<0); error('Video Source not selected.');
end;

%Para iniciar e calibrar o VET
vetCreateCameraScreen;
errorCode = vetCalibrate;
if(errorCode<0); error('Calibration not completed.');
end;

%Imagem para usar na tela Mimic (tela pequena no monitor 1)
ImageFile = which('C:\EyeTrackerLabirinto\labirinto_toxicologia.bmp');

%Configuracoes Gerais
vetClearAllRegions;  %Limpa as Regioes de Interesse (ROI) que podem estar na memoria do toolbox
vetClearDataBuffer;  %limpa rastreamento anterior
vetClearMimicscreenBitmap; %limpa a tela

vetCreateCameraScreen; %cria a tela em tempo real com o olho
%vetsetCameraScreenDimensions(0,0,300,266); %Tamanho do video
vetCreateMimicScreen; %A tela Mimic fornece feedback em tempo real de onde a pessoa olha
vetSetMimicScreenDimensions(300, 0, 300, 266);   %Tamanho da tela Mimic

%====Se quiser mudar o tempo em que o rastro na tela Mimic ficara ativo=========
vetSetMimicPersistence(50); %============O tempo em que o rastro na tela Mimic fica aparecendo (em segundos)

vetSetMimicPersistenceStyle(CRS.psConstant); %Nao deixa os tracos desparecerem
vetSetMimicPersistenceType(CRS.ptMotionAndFixations); %Mostra o movimento como linha e Fixacao como circulo expandido
vetLoadBmpFileToMimicScreen(ImageFile,1); %Desenha a tela Mimic, se "1", a escala e a mesma da imagem, se "2" a imagem sera adaptada a tela Mimici
vetSetFixationPeriod(100); %Fixa o tempo em quanto o olhar precisa permanecer estavel para ser considerado uma fixacao
vetSetFixationRange(20); %tamanho da area (mm) em que o olhar deve permanecer parado pelo periodo acima (100ms)

%--------------------------------------------------------------------------
%===========================PONTO DE FIXACAO===============================
% Seleicione a paleta de cores - deve ter 256 cores - para o fundo
% Inicia a ordem das cores na paleta.
palette = zeros(3,256);
palette(:,254) = [0,0,1]';       % Set pixel level 254 to Blue.(AZUL)
palette(:,255) = [0,1,0]';       % Set pixel level 255 to Green. (VERDE)
palette(:,256) = [1,0,0]';       % Set pixel level 256 to Red.(VERMELHO)
palette(:,1)   = [0.5,0.5,0.5]'; % Set pixel level 0 (the background) to mean grey.

crsPaletteSet(palette);

% Determina a altura e o comprimento da tela VSG em pixels.
Height = crsGetScreenHeightPixels;
Width  = crsGetScreenWidthPixels;

%PONTO (QUADRADO) FIXACAO
% Desenha a tela 1
crsSetDrawPage(1);
% Desenha o retangulo
black = [0,0,0];
crsPaletteSetPixelLevel(256, black);
%Desenha o retangulo (no VSG)
crsSetPen1(256);
crsDrawRect([0,0], [7,7]);
% Apresenta a tela 1
crsSetDisplayPage(1);
vetClearDataBuffer; %limpa o buffer
pause(2); %Determina por quanto tempo o ponto de fixacao ira aparecer

%=======================APRESENTACAO DO ESTIMULO===========================

% Apresenta uma tela em branco enquanto trabalho 
%crsSetDisplayPage(1);  %Arruma a tela a ser apresentada
%crsClearPage(2,1);  Lima a tela anterior para apresentar a atual
%crsSetDrawPage(2);
% Le a imagem da pasta e a desenha no monitor 2.  
crsDrawImage(CRS.PALETTELOAD,[0,0],'C:\EyeTrackerLabirinto\labirinto_toxicologia.bmp');
% Agora apresenta 
crsSetDisplayPage(1);
% Start tracking.  %%%%%%%%%%%%%%%APAGAR
%vetClearDataBuffer; APAGAR
%Inicia o rastreamento
vetStartTracking; %Rastreia por XXX ms a tela apresentada
%A funcao a seguir deve estar compativel com "vetSetMimicPersistence(xx); "
pause(); %==================================determina o tempo de rastreamento
%sem tempo o usuario tem  que apertar alguma tecla para continuar
vetStopTracking; %termina o rastreamento
crsClearPage(1); %limpa a pagina.
%--------------------------------------------------------------------------

% Arruma tudo limpando a tela com a camera e a Mimic
vetDestroyCameraScreen; %apaga a tela com o olho

%Deixar o comando abaixo inativo para poder salvar Mimic com Print Screen
%vetDestroyMimicScreen; %apaga a tela com a Mimic
global CRS;
vetSaveMimicScreenBitmap('C:\EyeTrackerLabirinto\Mimics.bmp');
     if(ischar('\C:\EyeTrackerLabirinto\Mimics.bmp')==0)
     error('filename must be a character array (MATLAB string).');
     else
     ErrorCode = vetmex(CRS.VETX_GetMimicWindowBitmap,'C:\EyeTrackerLabirinto\Mimics.bmp');
end


% Recuperar as posicoes gravadas do olho sem remove-las da memoria (buffer)
Remove = false;
DATA = vetGetBufferedEyePositions(Remove);

%Apresenta as posicoes recuperadas
figure(2); cla; hold on;
plot(DATA.mmPositions(:,1),'b'); %Longitude em azul (horizontal)
hold on;
plot(DATA.mmPositions(:,2),'r'); %Latitude em vermelho (vertical)
grid on;

%Salva os resultados no disco como um arquivo delimitado por vírgulas.
CurrentDirectory = cd;
tempfile = [CurrentDirectory,'\myResults.csv'];  %copiado, deve salvar na pasta onde esta o codigo
%tempfile = 'C:\myResults2.csv';

%tempfile = 'C:\EyeTrackerLabirinto\myResults.csv';
vetSaveResults(tempfile, CRS.ffCommaDelimitedNumeric);






% Clear the data buffer.
%vetClearDataBuffer;
