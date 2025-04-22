% 1. Cargar archivo CSV
filename = "C:\Users\Miguel Fernández\Desktop\Métodos Numéricos\TRABAJO SVD\movies.csv"; 

% 2. Leer el archivo CSV
dataTable = readtable(filename, 'PreserveVariableNames', true);

% 3. Extraer datos y nombres
data = table2array(dataTable(:, 2:end));
nombres_peliculas = dataTable.Properties.VariableNames(2:end);

% 4. Rellenar valores NaN por medias (primero por filas, luego por columnas)
for i = 1:size(data, 1)
    fila = data(i, :);
    data(i, isnan(fila)) = mean(fila, 'omitnan');
end
for j = 1:size(data, 2)
    columna = data(:, j);
    data(isnan(columna), j) = mean(columna, 'omitnan');
end

% 5. Vista previa de datos
disp('Vista previa de los datos:');
disp(data(1:5, 1:5));

% 6. Calcular SVD
[U, S, V] = svd(data, 'econ');

% 7. Mostrar matrices
disp('Vista previa de la matriz U (Usuarios):');
disp(U(1:5, 1:5));
disp(['Tamaño de la matriz U: ', num2str(size(U, 1)), 'x', num2str(size(U, 2))]);
disp('Vista previa de la matriz S (Valores Singulares no nulos):');
disp(S(1:5, 1:5));
disp(['Tamaño de la matriz S optimizada (de normal sería 944x1664): ', num2str(size(S, 1)), 'x', num2str(size(S, 2))]);
disp(['Número de valores singulares: ', num2str(length(diag(S)))]);

disp('Vista previa de la matriz V (Películas):');
disp(V(1:5, 1:5));
disp(['Tamaño de la matriz V optimizada (de normal sería 1664x1664): ', num2str(size(V, 1)), 'x', num2str(size(V, 2))]);

% 8. Curva de información acumulada
singular_values = diag(S);
info_total = sum(singular_values);
info_acumulada = cumsum(singular_values) / info_total * 100;

k = input('Introduce el número de valores singulares que deseas mantener (MAX 944): ');
if k > length(singular_values) || k < 1
    error('El número de valores singulares debe estar entre 1 y %d.', length(singular_values));
end

figure;
plot(1:length(singular_values), info_acumulada, '-o', 'LineWidth', 2);
hold on;
plot(k, info_acumulada(k), 'ro', 'MarkerFaceColor', 'r');
xlabel('Número de valores singulares');
ylabel('Información acumulada (%)');
title('Relación entre los valores singulares y la información acumulada');
grid on;
disp(['La información acumulada hasta el valor singular ', num2str(k), ' es: ', num2str(info_acumulada(k)), '%']);

% 9. Reducción dimensional
Uk = U(:, 1:k);
Sk = S(1:k, 1:k);
Vk = V(:, 1:k);

% Cálculo de coordenadas 3D
usuarios3D = Uk * Sk;
peliculas3D = Vk * Sk;

x1 = usuarios3D(:, 1); y1 = usuarios3D(:, 2); z1 = usuarios3D(:, 3);
x2 = peliculas3D(:, 1); y2 = peliculas3D(:, 2); z2 = peliculas3D(:, 3);

num_mostrados = min(k, size(x1, 1));
% Selección de los primeros 'num_mostrados' usuarios y películas
indices_usuarios = 1:num_mostrados; % Primero 'num_mostrados' usuarios
indices_peliculas = 1:num_mostrados; % Primero 'num_mostrados' películas

% --- CÁLCULO DE ESTADÍSTICAS PARA PELÍCULAS Y USUARIOS MOSTRADOS ---
% Extraer solo calificaciones de los usuarios y películas mostrados
calificaciones_mostradas = data(indices_usuarios, indices_peliculas);
calificaciones = calificaciones_mostradas(:);
calificaciones = calificaciones(~isnan(calificaciones));

% Estadísticas
min_cal = min(calificaciones);
max_cal = max(calificaciones);
media_cal = mean(calificaciones);
mediana_cal = median(calificaciones);
std_cal = std(calificaciones);
var_cal = var(calificaciones);

fprintf('\n--- Estadísticas de calificaciones de las películas y usuarios mostrados ---\n');
fprintf('Calificación mínima: %.1f\n', min_cal);
fprintf('Calificación máxima: %.1f\n', max_cal);
fprintf('Media de calificaciones: %.2f\n', media_cal);
fprintf('Mediana de calificaciones: %.1f\n', mediana_cal);
fprintf('Desviación típica: %.1f\n', std_cal);
fprintf('Varianza: %.1f\n', var_cal);

% Histograma
figure;
histogram(calificaciones, 'BinMethod', 'integers');
title('Distribución de Calificaciones (Usuarios y Películas mostrados)');
xlabel('Calificación');
ylabel('Frecuencia');
grid on;

% 10. Visualización 3D
figure;
scatter3(x1(indices_usuarios), y1(indices_usuarios), z1(indices_usuarios), 50, 'b', 'filled');
hold on;
scatter3(x2(indices_peliculas), y2(indices_peliculas), z2(indices_peliculas), 50, 'r', 'filled');
legend('Usuarios', 'Películas');
title(['Visualización 3D con SVD y ', num2str(k), ' componentes']);
xlabel('Componente 1'); ylabel('Componente 2'); zlabel('Componente 3');
grid on;

% 11. Activar cursor interactivo
d = datacursormode(gcf);
set(d, 'DisplayStyle', 'window', 'SnapToDataVertex', 'off', 'Enable', 'on');
set(d, 'UpdateFcn', @(obj, event_obj) display_info_on_click(obj, event_obj, ...
    x1, y1, z1, x2, y2, z2, nombres_peliculas, indices_usuarios, indices_peliculas, Vk));


fprintf('\n Haz click sobre un usuario para ver las 5 películas que se le recomiendan \n')
function recomendar_peliculas(usuario_idx, nombres_peliculas, Vk, indices_peliculas, num_recomendaciones)
    usuario_vector = Vk(usuario_idx, :);
    norma_usuario = norm(usuario_vector);
    if norma_usuario == 0
        disp(['No se pueden generar recomendaciones para el usuario ', num2str(usuario_idx), ' (vector nulo).']);
        return;
    end
    peliculas_mostradas = Vk(indices_peliculas, :);

    % Calcular normas
    normas_peliculas = vecnorm(peliculas_mostradas, 2, 2);
    usuario_normalizado = usuario_vector / norma_usuario;

    % Evitar división por cero
    normas_peliculas(normas_peliculas == 0) = eps;

    % Normalizar las películas
    peliculas_normalizadas = peliculas_mostradas ./ normas_peliculas;

    % Similitud coseno
    similitudes = peliculas_normalizadas * usuario_normalizado';

    [~, orden] = sort(similitudes, 'descend');
    mejores_peliculas = indices_peliculas(orden(1:num_recomendaciones));

    disp(['Películas recomendadas para el Usuario ', num2str(usuario_idx), ':']);
    for i = 1:length(mejores_peliculas)
        disp(['  - ', nombres_peliculas{mejores_peliculas(i)}]);
    end
    
end

function output_txt = display_info_on_click(~, event_obj, x1, y1, z1, x2, y2, z2, nombres_peliculas, indices_usuarios, indices_peliculas, Vk)
    pos = event_obj.Position;
    dist_usuarios = sqrt((x1(indices_usuarios) - pos(1)).^2 + (y1(indices_usuarios) - pos(2)).^2 + (z1(indices_usuarios) - pos(3)).^2);
    dist_peliculas = sqrt((x2(indices_peliculas) - pos(1)).^2 + (y2(indices_peliculas) - pos(2)).^2 + (z2(indices_peliculas) - pos(3)).^2);
    [~, idx_usuario] = min(dist_usuarios);
    [~, idx_pelicula] = min(dist_peliculas);

    if dist_usuarios(idx_usuario) < dist_peliculas(idx_pelicula)
        usuario_id = indices_usuarios(idx_usuario);
        output_txt = {['Usuario ID: ', num2str(usuario_id)]};
        recomendar_peliculas(usuario_id, nombres_peliculas, Vk, indices_peliculas, 5);
    else
        idx_pelicula_final = indices_peliculas(idx_pelicula);
        if idx_pelicula_final > 0 && idx_pelicula_final <= length(nombres_peliculas)
            movie_name = nombres_peliculas{idx_pelicula_final};
            output_txt = {['Película: ', char(movie_name)]};
        else
            output_txt = {'Película no encontrada.'};
        end
    end
end
