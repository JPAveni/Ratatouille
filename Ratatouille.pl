rata(remy, gusteaus).
rata(emile, bar).
rata(django, pizzeria).

cocina(linguini, ratatouille, 3).
cocina(linguini, sopa, 5).
cocina(linguini, salmonAsado, 10).
cocina(colette, salmonAsado, 9).
cocina(horst, ensaladaRusa, 8).

trabajaEn(gusteaus, linguini).
trabajaEn(gusteaus, colette).
trabajaEn(gusteaus, skinner).
trabajaEn(gusteaus, horst).
trabajaEn(cafeDes2Moulins, amelie).

/*------1------
inspeccionSatisfactoria/1 se cumple para un restaurante cuando no viven ratas allí.
*/
inspeccionSatisfactoria(Restaurante):-
    trabajaEn(Restaurante,_),
    not(vivenRatasEnElRestaurante(Restaurante)).

vivenRatasEnElRestaurante(Restaurante):-
rata(_,Restaurante).

/*------2------
2. chef/2: relaciona un empleado con un restaurante si el empleado trabaja allí y sabe cocinar algún plato.
*/
chef(Empleado,Restaurante):-
trabajaEn(Restaurante,Empleado),
cocina(Empleado,_,_).

/*------3------
chefcito/1: se cumple para una rata si vive en el mismo restaurante donde trabaja linguini.
*/
chefcito(Rata):-
rata(Rata,Restaurante),
chef(linguini,Restaurante).

/*------4------
cocinaBien/2 es verdadero para una persona si su experiencia preparando ese plato es mayor a 7. Además, remy cocina bien cualquier plato que exista.
*/
cocinaBien(Cocinero,Plato):-
cocina(_, Plato,_),
condicionDeCocinarBien(Cocinero,Plato).

condicionDeCocinarBien(remy,_).
condicionDeCocinarBien(Cocinero,Plato):-
cocina(Cocinero,Plato,Valoracion),
Valoracion > 7.


/*------5------
encargadoDe/3: nos dice el encargado de cocinar un plato en un restaurante, que es quien más experiencia tiene preparándolo en ese lugar.
Ahora conseguimos un poco más de información sobre los platos. Los dividimos en entradas, platos principales y postres:
*/

encargadoDe(Restaurante,Plato,Cocinero):-
chef(Cocinero,Restaurante),
cocina(Cocinero,Plato,Valoracion),
forall((cocina(OtroCocinero, Plato,OtraValoracion),chef(OtroCocinero,Restaurante),OtroCocinero\=Cocinero), Valoracion > OtraValoracion).


/*------6------

De las entradas sabemos qué ingredientes las componen; 
de los principales, qué guarnición los acompaña y cuántos minutos de cocción precisan;
de los postres, cuántas calorías aportan.

saludable/1: un plato es saludable si tiene menos de 75 calorías.
En las entradas, cada ingrediente suma 15 calorías.
Los platos principales suman 5 calorías por cada minuto de cocción. 
Las guarniciones agregan a la cuenta total: 
las papasFritas 50 y el puré 20, mientras que la ensalada no aporta calorías.
De los postres ya conocemos su cantidad de calorías.

caloriasPorPlato(plato(frutillasConCrema, postre(265)),Calorias).
*/
plato(ensaladaRusa, entrada([papa, zanahoria, arvejas, huevo, mayonesa])).
plato(bifeDeChorizo, principal(pure, 25)).
plato(frutillasConCrema, postre(265)).

saludable(Plato):-
plato(Plato,_),
caloriasPorPlato(Plato,Calorias),
esBajoEnCalorias(Calorias).

caloriasPorPlato(Plato,Calorias):-
plato(Plato,postre(Calorias)).
caloriasPorPlato(Plato,Calorias):-
plato(Plato,entrada(Ingredientes)),
length(Ingredientes,CantidadDeIngredientes),
Calorias is CantidadDeIngredientes * 15.
caloriasPorPlato(Plato,Calorias):-
plato(Plato,principal(Guarnicion,Tiempo)),
caloriasPorGuarnicion(Guarnicion,CaloriasDeLaGuarnicion),
Calorias is Tiempo * 5 + CaloriasDeLaGuarnicion.

esBajoEnCalorias(Calorias):-
Calorias < 75.

caloriasPorGuarnicion(papasFritas,50).
caloriasPorGuarnicion(pure,20).
caloriasPorGuarnicion(ensalada,0).
/*------7------
criticaPositiva/2: es verdadero para un restaurante si un crítico le escribe una reseña positiva. 
Cada crítico maneja su propio criterio, pero todos están de acuerdo en lo mismo: el lugar debe tener una inspección satisfactoria.	
antonEgo espera, además, que en el lugar sean especialistas preparando ratatouille. Un restaurante es especialista en 
aquellos platos que todos sus chefs saben cocinar bien.
# christophe, que el restaurante tenga más de 3 chefs.
# cormillot requiere que todos los platos que saben cocinar los empleados del restaurante sean saludables y que a ninguna entrada le falte zanahoria.
# gordonRamsay no le da una crítica positiva a ningún restaurante.
*/
criticaPositiva(Restaurante,Critico):-
inspeccionSatisfactoria(Restaurante),
Critico \= gordonRamsay,
criterioDeCritico(Restaurante,Critico).

criterioDeCritico(Restaurante,antonEgo):-
especialistaEn(Restaurante,ratatouille).

criterioDeCritico(Restaurante,christophe):-
tieneMasDeTantosChefs(3,Restaurante).

criterioDeCritico(Restaurante,cormillot):-
todosPlatosSaludables(Restaurante),
forall(plato(_,entrada(Ingredientes)),member(zanahoria, Ingredientes)).


especialistaEn(Restaurante,Plato):-
forall(chef(Cocinero,Restaurante),cocinaBien(Cocinero,Plato)).

tieneMasDeTantosChefs(Numero,Restaurante):-
findall(Cocinero,chef(Cocinero,Restaurante),Cocineros),
length(Cocineros,CantidadDeCocineros),
CantidadDeCocineros > Numero.

todosPlatosSaludables(Restaurante):-
trabajaEn(Restaurante,_),
forall(cocina(_,Plato,_),saludable(Plato)).
