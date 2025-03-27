% -----------------------
% EXPLORACIÓN DE DATOS - Sistema de Recomendación
% -----------------------

% Cargar datos desde CSV
data = readmatrix('movies.csv');  % Ignora cabeceras
user_ids = data(:,1);             % ID de usuario
R = data(:,2:end);                % Matriz de calificaciones

% Número de usuarios y películas
[num_users, num_movies] = size(R);
fprintf('Número de usuarios: %d\n', num_users);
fprintf('Número de películas: %d\n', num_movies);

% Total de valores posibles y reales
total_valores = num_users * num_movies;
valores_presentes = nnz(~isnan(R));
porcentaje_lleno = (valores_presentes / total_valores) * 100;

fprintf('Total de posibles calificaciones: %d\n', total_valores);
fprintf('Número de calificaciones presentes: %d\n', valores_presentes);
fprintf('Porcentaje de matriz llena: %.2f%%\n', porcentaje_lleno);

% Calificaciones existentes
calificaciones = R(~isnan(R));

% Estadísticas descriptivas
min_cal = min(calificaciones);
max_cal = max(calificaciones);
media_cal = mean(calificaciones);
mediana_cal = median(calificaciones);

fprintf('Calificación mínima: %.1f\n', min_cal);
fprintf('Calificación máxima: %.1f\n', max_cal);
fprintf('Media de calificaciones: %.2f\n', media_cal);
fprintf('Mediana de calificaciones: %.1f\n', mediana_cal);

% Histograma de calificaciones
figure;
histogram(calificaciones, 'BinMethod', 'integers');
title('Distribución de Calificaciones');
xlabel('Calificación');
ylabel('Frecuencia');
