package com.api_ec2.movie_recommendation_api.controller;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.api_ec2.movie_recommendation_api.model.Pelicula;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/recommendations")
public class RecommendationController {

    //Lista de prueba
    private List<Pelicula> peliculasLista = Arrays.asList(
        new Pelicula("Harry Potter", "Fantasía"),
        new Pelicula("Sherk", "Comedia animada"),
        new Pelicula("IT", "Terror")
    );

    @GetMapping
    public List<String> getRecommendations(@RequestParam(value = "genre", required = false) String preferedGenre) {
        if (preferedGenre != null && !preferedGenre.trim().isEmpty()) {
            return peliculasLista.stream()
                    .filter(movie -> movie.getGenre().equalsIgnoreCase(preferedGenre))
                    .map(Pelicula::getTitle)
                    .collect(Collectors.toList());
        } else {
            //El género es opcional
            return Arrays.asList("Película(s) recomendadas: ");
        }
        
    }
}