%% ------------------------INTRO--------------------
/*"No cualquiera puede convertirse en un gran artista, pero un gran 
artista puede provenir de cualquier lado"
¡Bonjour! En una ciudad donde ratas y humanos saben cocinar, 
tenemos la siguiente información en nuestra base de conocimiento:
*/

rata(remy, gusteaus).
rata(emile, bar).
rata(django, pizzeria).
cocina(linguini, ratatouille, 3).
cocina(linguini, sopa, 5).
cocina(colette, salmonAsado, 9).
cocina(horst, ensaladaRusa, 8).


/*
De las ratas sabemos su nombre y dónde viven. De los humanos,
además de su nombre, qué platos saben cocinar y cuánta experiencia 
(del 1 al 10) tienen preparándolos. También tenemos información
acerca de quién trabaja en cada restaurante:
*/

trabajaEn(gusteaus, linguini).
trabajaEn(gusteaus, colette).
trabajaEn(gusteaus, skinner).
trabajaEn(gusteaus, horst).
trabajaEn(cafeDes2Moulins, amelie).

%% Desarrollá los siguientes predicados, asegurando que sean
%% completamente inversibles

/* 1. inspeccionSatisfactoria/1 se cumple para un
restaurante cuando no viven ratas allí */

inspeccionSatisfactoria(Restaurante):-
trabajaEn(Restaurante,_),
not(rata(_,Restaurante)).

/*2. chef/2: relaciona un empleado con un restaurante si el
empleado trabaja allí y sabe cocinar algún plato.*/

chef(Empleado,Restaurante):-
trabajaEn(Restaurante,Empleado),
cocina(Empleado,_,_).

/*3. chefcito/1: se cumple para una rata si vive en el mismo
restaurante donde trabaja linguini.*/

chefcito(Rata):-
rata(Rata,Restaurante),
trabajaEn(Restaurante,linguini).


/*4. cocinaBien/2 es verdadero para una persona si su experiencia
preparando ese plato es mayor a 7. Además, remy cocina bien cualquier 
plato que exista.
*/

cocinaBien(Persona,Plato):-
cocina(Persona,Plato,Experiencia),
Experiencia>7.

cocinaBien(remy,Plato):-
cocina(_,Plato,_).

cocinaBien(remy,Plato):-
plato(Plato,_).


/*
5. encargadoDe/3: nos dice el encargado de cocinar un plato en un 
restaurante, que es quien más experiencia tiene preparándolo en ese lugar.
*/

encargadoDe(Persona,Plato,Restaurante):-
trabajaEn(Restaurante,Persona),
cocina(Persona,Plato,MayorExperiencia),
forall(cocinaEnElMismoRestaurante(_,Plato,Restaurante,Experiencia),Experiencia=<MayorExperiencia).

cocinaEnElMismoRestaurante(Persona,Plato,Restaurante,Experiencia):-
trabajaEn(Restaurante,Persona),
cocina(Persona,Plato,Experiencia).

/*
Ahora conseguimos un poco más de información sobre los platos. 
Los dividimos en entradas, platos principales y postres:
*/

plato(ensaladaRusa, entrada([papa, zanahoria, arvejas, huevo, mayonesa])).
plato(bifeDeChorizo, principal(pure, 25)).
plato(frutillasConCrema, postre(265)).


/*
De las entradas sabemos qué ingredientes las componen; de los principales,
qué guarnición los acompaña y cuántos minutos de cocción precisan; y
de los postres, cuántas calorías aportan.
*/

/*

6. saludable/1: un plato es saludable si tiene menos de 75 calorías.
● En las entradas, cada ingrediente suma 15 calorías.
● Los platos principales suman 5 calorías por cada minuto de cocción. 
Las guarniciones agregan a la cuenta total: las papasFritas 50 y el puré 20,
mientras que la ensalada no aporta calorías.
● De los postres ya conocemos su cantidad de calorías.
Pero además, un postre también puede ser saludable si algún grupo del curso 
tiene ese nombre de postre. 
Usá el predicado grupo/1 como hecho y da un ejemplo con tu nombre de grupo.
*/

grupo(chocotorta).
grupo(mousseDeDulceDeLeche).

saludable(Plato):-
plato(Plato,TipoPlato),
caloriasDelPlato(TipoPlato,Calorias),
Calorias<75.

saludable(Plato):-
    grupo(Plato).

caloriasDelPlato(entrada(ListaIngredientes),Calorias):-
length(ListaIngredientes,CantIngredientes),
Calorias is CantIngredientes*15.

caloriasDelPlato(principal(Guarnicion,Coccion),Calorias):-
    CaloriasCoccion is Coccion*5,
    guarnicionCalorias(Guarnicion,CaloriasGuarnicion),
    Calorias is CaloriasGuarnicion + CaloriasCoccion.

caloriasDelPlato(postre(Calorias),Calorias).



guarnicionCalorias(papasFritas,50).
guarnicionCalorias(pure,20).
guarnicionCalorias(ensalada,0).


/*
7. criticaPositiva/2: es verdadero para un restaurante si un crítico le escribe 
una reseña positiva. Cada crítico maneja su propio criterio, pero todos están 
de acuerdo en lo mismo: el lugar debe tener una inspección satisfactoria.
● antonEgo espera, además, que en el lugar sean especialistas preparando 
ratatouille. Un restaurante es especialista en aquellos platos que todos sus 
chefs saben cocinar bien.
● christophe, que el restaurante tenga más de 3 chefs.
● cormillot requiere que todos los platos que saben cocinar los empleados del 
restaurante sean saludables y que a ninguna entrada le falte zanahoria.
● gordonRamsay no le da una crítica positiva a ningún restaurante.

*/

criticaPositiva(Critico,Restaurante):-
inspeccionSatisfactoria(Restaurante),
cumpleCriterio(Critico,Restaurante).


cumpleCriterio(antonEgo,Restaurante):-
forall(chef(Persona,Restaurante),cocinaBien(Persona,ratatouille)).

cumpleCriterio(christophe,Restaurante):-
    findall(Chef,chef(Chef,Restaurante),ListaChefsConRepeticion),
    list_to_set(ListaChefsConRepeticion, ListaChefs),
    length(ListaChefs,CantChefs),
    CantChefs>3.

cumpleCriterio(cormillot,Restaurante):-
    forall(platoDeUnEmpleado(Plato,Restaurante),saludable(Plato)),
    not(aUnaEntradaLeFaltaZanahoria(Restaurante)).


platoDeUnEmpleado(Plato,Restaurante):-
    trabajaEn(Restaurante,Empleado),
    cocina(Empleado,Plato,_).

aUnaEntradaLeFaltaZanahoria(Restaurante):-
    platoDeUnEmpleado(Plato,Restaurante),
    plato(Plato,TipoPlato),
    esEntradaYLeFaltaZanahoria(TipoPlato).

esEntradaYLeFaltaZanahoria(entrada(ListaIngredientes)):-
    not(member(zanahoria,ListaIngredientes)).







