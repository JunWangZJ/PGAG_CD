function A = connection2adjacency(C)
% 将 N×k 连接矩阵转换为 N×N 邻接矩阵
% 输入：
%   C : N×k 矩阵，每行存储该顶点连接的邻居序号（顶点从 1 开始编号）
% 输出：
%   A : N×N 邻接矩阵，A(i,j)=1 表示顶点i与j相连

    [N, k] = size(C);
    A = zeros(N, N);
    
    for i = 1:N
        neighbors = C(i, :);
        % 去除可能的无效索引（如填充的0）
        valid_neighbors = neighbors(neighbors >= 1 & neighbors <= N);
        A(i, valid_neighbors) = 1;
    end
    
    % 若需强制无向图，取消注释下一行（确保对称性）
    % A = max(A, A');
end