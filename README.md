# 室内定位演示系统 (Indoor Positioning Demonstration System)

基于 MATLAB 的室内定位算法可视化演示系统，本科毕业设计项目。

## 功能

- **RSS 测距定位**：基于对数距离路径损耗模型，利用最小二乘法估计目标位置
- **Wi-Fi 指纹定位**：离线构建 RSS 指纹库，在线 KNN/WKNN 匹配定位
- **GUI 交互**：基于 MATLAB uifigure 的四页面图形界面，支持参数调节和点击设定目标位置
- **批量测试**：支持 20 次批量运行，自动记录误差并绘制历史误差折线图

## 运行环境

- MATLAB R2024a 或更高版本

## 快速开始

1. 用 MATLAB 打开项目文件夹
2. 运行 `localization.m`
3. 在首页选择"进入测距定位"或"进入指纹定位"

## 文件说明

| 文件 | 说明 |
|------|------|
| `localization.m` | 主程序（GUI），包含 RSS 测距页、指纹定位页、批量测试和历史误差曲线 |
| `WKNN.m` | WKNN 与 KNN 算法核心函数 |
| `RadiomapGenWKNN.m` | 指纹数据库（Radiomap）生成函数 |
| `localization_GUI_multiPage.m` | 多页面 GUI 框架实现 |
| `KNN_GUI.m` / `RSS_GUI.m` / `RSSgui.m` | 各模块早期 GUI 版本 |
| `RSS1.m` / `RSSF1.m` / `RSSF2.m` / `RSSch1.m` | RSS 测距定位的不同实现变体 |
| `RSSKNN1.m` / `fingerprint_knn.m` / `rss_localization.m` | KNN 指纹定位的不同实现变体 |
| `localization.prj` | MATLAB 项目配置文件 |

## 作者

- **方汉宇** — 上海理工大学 光电信息与计算机工程学院 通信工程专业
- 指导教师：乐燕芬
- 完成日期：2026 年 4 月
