function localization
clc;close all;
fig=uifigure('Name','室内定位演示系统','Position',[200 200 1050 550]);

% 创建页面
pages.home=uipanel(fig,'Position',[1 1 1050 550]);
pages.rss=uipanel(fig,'Position',[1 1 1050 550],'Visible','off');
pages.fp=uipanel(fig,'Position',[1 1 1050 550],'Visible','off');
pages.wknn=uipanel(fig,'Position',[1 1 1050 550],'Visible','off');

% home页
uilabel(pages.home,'Text','室内定位演示系统','FontSize',30, ...
    'Position',[420 430 300 40]);
uilabel(pages.home,'Text','作者:方汉宇','FontSize',18,...
    'Position',[490 380 300 40]);
uilabel(pages.home,'Text','请选择定位方式','FontSize',18,...
    'Position',[475 310 300 40]);

uibutton(pages.home,'push','Text','进入测距定位','Position',[280 230 200 50],...
    'ButtonPushedFcn',@(btn,event) switchPage(pages.rss));
uibutton(pages.home,'push','Text','进入指纹定位','Position',[600 230 200 50],...
    'ButtonPushedFcn',@(btn,event) switchPage(pages.fp));

%% 页面切换
function switchPage(targetPage)
    names = fieldnames(pages);
    for i = 1:length(names)
        pages.(names{i}).Visible = 'off';
    end
    targetPage.Visible = 'on';
end


%% 测距页
uilabel(pages.rss,'Text','锚点数量','Position',[20 500 80 20]);
rss_param = uieditfield(pages.rss,'numeric','Position',[80 500 60 22],'Value',4);

uilabel(pages.rss,'Text','目标坐标','Position',[170 500 80 20]);
rss_target = uieditfield(pages.rss,'text','Position',[230 500 100 22],'Value','[50 50]');

uibutton(pages.rss,'push','Text','运行','Position',[750 500 80 22],...
    'ButtonPushedFcn',@(btn,event) runRSS());
uibutton(pages.rss,'push','Text','返回首页','Position',[850 500 100 22],...
    'ButtonPushedFcn',@(btn,event) switchPage(pages.home));
% 坐标区
rss_ax = uiaxes(pages.rss);
rss_ax.Position = [20 60 700 400];
axis(rss_ax,[0 100 0 100]); grid(rss_ax,'on')
title(rss_ax,'RSS定位结果')
rss_ax.ButtonDownFcn = @(~,~) rssClick();
% 结果显示区
rss_result = uitextarea(pages.rss);
rss_result.Position = [750 200 250 250];

%% 指纹页
uilabel(pages.fp,'Text','AP坐标','Position',[20 470 60 20]);
wknn_ap = uieditfield(pages.fp,'text','Position',[80 470 250 22],'Value', ...
    '[25 25;25 75;50 10;50 50;50 90;75 25;75 75]');
uilabel(pages.fp,'Text','网格间距','Position',[20 500 80 20]);
wknn_param1 = uieditfield(pages.fp,'numeric','Position',[80 500 60 22],'Value',5);
uilabel(pages.fp,'Text','K值','Position',[170 500 80 20]);
wknn_param2 = uieditfield(pages.fp,'numeric','Position',[200 500 60 22],'Value',3);
uilabel(pages.fp,'Text','目标坐标','Position',[290 500 80 20]);
wknn_target = uieditfield(pages.fp,'text','Position',[350 500 100 22],'Value','[50 50]');


uibutton(pages.fp,'push','Text','运行','Position',[750 500 80 22],...
    'ButtonPushedFcn',@(btn,event) runFPwknn());
uibutton(pages.fp,'push','Text','返回首页','Position',[850 500 80 22],...
    'ButtonPushedFcn',@(btn,event) switchPage(pages.home));
% 运行20次按钮
uibutton(pages.fp,'push','Text','运行20次','Position',[750 470 80 22],...
    'ButtonPushedFcn',@(btn,event) runFPwknn20());

wknn_ax = uiaxes(pages.fp);
wknn_ax.Position = [20 60 700 400];
axis(wknn_ax,[0 100 0 100]); grid(wknn_ax,'on')
title(wknn_ax,'指纹定位结果')

wknn_result = uitextarea(pages.fp);
wknn_result.Position = [750 200 250 250];

hist_wknn_data = zeros(1,20);
hist_knn_data  = zeros(1,20);
hist_count_data = 0;

% 历史折现图
history_ax = uiaxes(pages.fp);
history_ax.Position = [750 20 250 170];
title(history_ax,'最近20次定位误差');
xlabel(history_ax,'次数');
ylabel(history_ax,'误差(m)');
grid(history_ax,'on');

%% RSS运行
function runRSS()
    RSS0 = -40;
    n_pl = 2.5;
    d0 = 1;
num_anchors = round(rss_param.Value);
    if num_anchors < 3
       uialert(fig,'锚点数量必须≥3','输入错误');
       return
    end
    
    try
       target = eval(rss_target.Value);
    catch
       uialert(fig,'坐标格式应为 [x y]','输入错误');
       return
    end

    % 随机锚点
    x = rand(num_anchors,1)*100;
    y = rand(num_anchors,1)*100;
    anchors = [x y];
    % 加入噪声
    noise = randn(num_anchors,1)*3;
    distances = sqrt(sum((anchors-target).^2,2));
    noisedistances = distances + noise;
    % 线性最小二乘定位
    A=zeros(num_anchors-1,2);
    b=zeros(num_anchors-1,1);

for i=2:num_anchors
    A(i-1,:)=2*(anchors(i,:)-anchors(1,:));
    b(i-1)=anchors(i,1)^2+anchors(i,2)^2 ...
        -anchors(1,1)^2-anchors(1,2)^2 ...
        +noisedistances(1)^2-noisedistances(i)^2;
end

    est_target_ls = (A\b)';
    error_ls = norm(est_target_ls-target);

% 绘图
    cla(rss_ax)

    h1=plot(rss_ax,anchors(:,1),anchors(:,2),'bs','MarkerSize',10);
    hold(rss_ax,'on')

    h2=plot(rss_ax,target(1),target(2),'ro','MarkerSize',10);
    h3=plot(rss_ax,est_target_ls(1),est_target_ls(2),'g^','MarkerSize',10);

    legend(rss_ax,{'锚点','真实位置','估计位置'})
    axis(rss_ax,[0 100 0 100])
    grid(rss_ax,'on')
    set([h1,h2,h3], 'HitTest', 'off');

    rss_result.Value = {
            '——路径损耗模型参数——'
            ['RSS0 = ',num2str(RSS0),' dBm']
            ['n = ',num2str(n_pl)]
            ['d0 = ',num2str(d0),' m']
            '——定位结果——'
            ['真实位置: ',num2str(target)]
            ['估计位置: ',num2str(est_target_ls)]
            ['定位误差: ',num2str(error_ls),' m']
            };

end

function rssClick()
    cp = rss_ax.CurrentPoint;
    x = cp(1,1); y = cp(1,2);
    if x >= 0 && x <= 100 && y >= 0 && y <= 100
        rss_target.Value = sprintf('[%g %g]', x, y);
        runRSS();
    end
end

%% 指纹运行
function runFPwknn()
    try
        target = eval(wknn_target.Value);
    catch
        uialert(fig,'坐标格式错误','错误');
        return
    end

    grid_step = wknn_param1.Value;
    K = wknn_param2.Value;

    % 读取AP
    try
        ap = eval(wknn_ap.Value);
    catch
        uialert(fig,'AP坐标格式错误','错误');
        return
    end

    % 生成网格
    [xg, yg] = meshgrid(0:grid_step:100, 0:grid_step:100);
    ref_points = [xg(:), yg(:)];
    num_points = size(ref_points,1);
    num_ap = size(ap,1);

    % 创建指纹库
    rssi_fgpt = zeros(num_points, num_ap);

    for i = 1:num_points
        for j = 1:num_ap
            d = norm(ref_points(i,:) - ap(j,:));
            rssi_fgpt(i,j) = -30 - 20*log10(d+1) + randn*1;
        end
    end

    % 生成目标RSS
    rssi = zeros(1,num_ap);
    for j = 1:num_ap
        d = norm(target - ap(j,:));
        rssi(j) = -30 - 20*log10(d+1) + randn*1;
    end

    % WKNN
    [xw,yw,xk,yk] = WKNN(K,rssi_fgpt,ref_points,rssi);

    est_wknn = [xw yw];
    est_knn = [xk yk];

    err_wknn = norm(est_wknn - target);
    err_knn = norm(est_knn - target);

    % 绘图
    cla(wknn_ax)

    plot(wknn_ax,ref_points(:,1),ref_points(:,2),'.','Color',[0.8 0.8 0.8])
    hold(wknn_ax,'on')
    plot(wknn_ax,ap(:,1),ap(:,2),'bs','MarkerSize',10)
    plot(wknn_ax,target(1),target(2),'ro','MarkerSize',10)
    plot(wknn_ax,est_wknn(1),est_wknn(2),'g^','MarkerSize',10)
    plot(wknn_ax,est_knn(1),est_knn(2),'k*','MarkerSize',10)

    legend(wknn_ax,{'参考点','AP','真实位置','WKNN','KNN'})
    
    % 历史误差记录更新
    if hist_count_data < 20
        hist_count_data = hist_count_data + 1;
        hist_wknn_data(hist_count_data) = err_wknn;
        hist_knn_data(hist_count_data) = err_knn;
    else
        hist_wknn_data = [hist_wknn_data(2:20), err_wknn];
        hist_knn_data  = [hist_knn_data(2:20),  err_knn];
    end
    
    
    % 计算近20次平均
    if hist_count_data <= 20
        avg_wknn = mean(hist_wknn_data(1:hist_count_data));
        avg_knn = mean(hist_knn_data(1:hist_count_data));
    else
        avg_wknn = mean(hist_wknn_data);
        avg_knn = mean(hist_knn_data);
    end
    
    % 更新折线图
    cla(history_ax);
    hold(history_ax, 'on');
    n = min(hist_count_data, 20);
    if hist_count_data <= 20
        plot(history_ax, 1:n, hist_wknn_data(1:n), 'b-o', 'LineWidth', 1.5);
        plot(history_ax, 1:n, hist_knn_data(1:n), 'y-o', 'LineWidth', 1.5);
    else
        plot(history_ax, 1:20, hist_wknn_data, 'b-o', 'LineWidth', 1.5);
        plot(history_ax, 1:20, hist_knn_data, 'y-o', 'LineWidth', 1.5);
    end
    legend(history_ax, {'WKNN','KNN'}, 'Location', 'best');
    grid(history_ax, 'on');
    hold(history_ax, 'off');

    % 输出（单次结果 + 近20次平均）
    wknn_result.Value = {
        '——WKNN定位——'
        ['WKNN误差: ',num2str(err_wknn),' m']
        ['KNN误差: ',num2str(err_knn),' m']
        ' '
        '——近20次平均——'
        ['WKNN: ',num2str(avg_wknn),' m']
        ['KNN: ',num2str(avg_knn),' m']
        };

end

%% 指纹运行20次
function runFPwknn20()
    try
        target = eval(wknn_target.Value);
    catch
        uialert(fig,'坐标格式错误','错误');
        return
    end

    % 读取用户输入的AP坐标
    try
        ap = eval(wknn_ap.Value);
    catch
        uialert(fig,'AP坐标格式错误','错误');
        return
    end

    grid_step = wknn_param1.Value;
    K = wknn_param2.Value;

    % 生成网格
    [xg, yg] = meshgrid(0:grid_step:100, 0:grid_step:100);
    ref_points = [xg(:), yg(:)];
    num_points = size(ref_points,1);
    num_ap = size(ap,1);

    errs_wknn = zeros(1,20);
    errs_knn = zeros(1,20);
    est_wknn_last = [0 0];
    est_knn_last = [0 0];
    
    for t = 1:20
        % 创建指纹库
        rssi_fgpt = zeros(num_points, num_ap);
        for i = 1:num_points
            for j = 1:num_ap
                d = norm(ref_points(i,:) - ap(j,:));
                rssi_fgpt(i,j) = -30 - 20*log10(d+1) + randn*1;
            end
        end
        
        % 生成目标RSS
        rssi = zeros(1,num_ap);
        for j = 1:num_ap
            d = norm(target - ap(j,:));
            rssi(j) = -30 - 20*log10(d+1) + randn*1;
        end

        % WKNN
        [xw,yw,xk,yk] = WKNN(K,rssi_fgpt,ref_points,rssi);
        est_wknn_last = [xw yw];
        est_knn_last = [xk yk];
        errs_wknn(t) = norm(est_wknn_last - target);
        errs_knn(t) = norm(est_knn_last - target);
        
        % 历史队列
        if hist_count_data < 20
            hist_count_data = hist_count_data + 1;
            hist_wknn_data(hist_count_data) = errs_wknn(t);
            hist_knn_data(hist_count_data) = errs_knn(t);
        else
            hist_wknn_data = [hist_wknn_data(2:20), errs_wknn(t)];
            hist_knn_data  = [hist_knn_data(2:20),  errs_knn(t)];
        end
    end

    mean_err_wknn = mean(errs_wknn);
    mean_err_knn = mean(errs_knn);
    
    % 计算当前近20次总平均
    if hist_count_data <= 20
        avg_wknn = mean(hist_wknn_data(1:hist_count_data));
        avg_knn = mean(hist_knn_data(1:hist_count_data));
    else
        avg_wknn = mean(hist_wknn_data);
        avg_knn = mean(hist_knn_data);
    end

    % 绘图（用最后一次的估计位置）
    cla(wknn_ax);
    plot(wknn_ax,ref_points(:,1),ref_points(:,2),'.','Color',[0.8 0.8 0.8]);
    hold(wknn_ax,'on');
    plot(wknn_ax,ap(:,1),ap(:,2),'bs','MarkerSize',10);
    plot(wknn_ax,target(1),target(2),'ro','MarkerSize',10);
    plot(wknn_ax,est_wknn_last(1),est_wknn_last(2),'g^','MarkerSize',10);
    plot(wknn_ax,est_knn_last(1),est_knn_last(2),'k*','MarkerSize',10);
    legend(wknn_ax,{'参考点','AP','真实位置','WKNN','KNN'});

    % 更新折线图
    cla(history_ax);
    hold(history_ax, 'on');
    if hist_count_data <= 20
        n = hist_count_data;
        plot(history_ax, 1:n, hist_wknn_data(1:n), 'b-o', 'LineWidth', 1.5);
        plot(history_ax, 1:n, hist_knn_data(1:n), 'y-o', 'LineWidth', 1.5);
    else
        plot(history_ax, 1:20, hist_wknn_data, 'b-o', 'LineWidth', 1.5);
        plot(history_ax, 1:20, hist_knn_data, 'y-o', 'LineWidth', 1.5);
    end
    legend(history_ax, {'WKNN','KNN'}, 'Location', 'best');
    grid(history_ax, 'on');
    hold(history_ax, 'off');

    % 输出：只显示平均误差
    wknn_result.Value = {
        '——20次运行平均——'
        ['WKNN平均误差: ',num2str(mean_err_wknn),' m']
        ['KNN平均误差: ',num2str(mean_err_knn),' m']
        ' '
        '——近20次平均——'
        ['WKNN: ',num2str(avg_wknn),' m']
        ['KNN: ',num2str(avg_knn),' m']
        };
end

end