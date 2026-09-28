import numpy as np
from scipy.integrate import odeint
import matplotlib.pyplot as plt
import os

# 1. Definir el sistema de ecuaciones diferenciales no lineales (Lorenz)
def lorenz(state, t, sigma, rho, beta):
    x, y, z = state
    dxdt = sigma * (y - x)
    dydt = x * (rho - z) - y
    dzdt = x * y - beta * z
    return [dxdt, dydt, dzdt]

# 2. Condiciones iniciales y parámetros de caos
sigma = 10.0
rho = 28.0     # Prueba cambiar este valor a 14.0 o 99.0 después de la primera ejecución
beta = 8.0/3.0
state0 = [1.0, 1.0, 1.0]
t = np.arange(0.0, 40.0, 0.01) # Resolver para 4000 pasos de tiempo

# 3. Integración numérica (Runge-Kutta mediante scipy)
print("Calculando integración numérica...")
states = odeint(lorenz, state0, t, args=(sigma, rho, beta))
x = states[:, 0]
y = states[:, 1]
z = states[:, 2]

# 4. Renderizar gráfica 3D
print("Generando visualización...")
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')
ax.plot(x, y, z, color='blue', lw=0.5)
ax.set_title(f"Atractor de Lorenz (rho={rho})")
ax.set_axis_off()

# 5. Exportar al servidor web de Apache
plt.savefig('/var/www/html/lorenz.png', bbox_inches='tight', dpi=150)

html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>AWS SBG - Math Computacional</title>
    <style>
        body {{ font-family: system-ui; text-align: center; background-color: #f8f9fa; margin-top: 50px; }}
        .container {{ background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: inline-block; }}
        h1 {{ color: #232F3E; }}
        .math {{ background: #eee; padding: 10px; border-radius: 5px; font-family: monospace; display: inline-block; text-align: left; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>Simulación de Sistemas Dinámicos en AWS</h1>
        <p>Integración numérica de un modelo caótico procesado en Amazon EC2.</p>
        
        <div class="math">
            dx/dt = &sigma;(y - x)<br>
            dy/dt = x(&rho; - z) - y<br>
            dz/dt = xy - &beta;z<br>
            <br>
            <strong>Parámetros actuales:</strong><br>
            &sigma; = {sigma} | &rho; = {rho} | &beta; = {beta:.2f}
        </div>
        
        <br><br>
        <img src="lorenz.png" alt="Atractor de Lorenz" width="600">
    </div>
</body>
</html>
"""

with open('/var/www/html/index.html', 'w') as f:
    f.write(html_content)

print("¡Éxito! Simulación completada. Entra a la IP de tu EC2 en tu navegador.")
