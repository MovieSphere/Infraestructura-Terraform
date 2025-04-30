package com.api_ec2.movie_recommendation_api.model;

public class Pelicula {
    private String title;
    private String genre;

    public Pelicula(String title, String genre) {
        this.title = title;
        this.genre = genre;
    }

    public String getTitle() {
        return title;
    }

    public String getGenre() {
        return genre;
    }
}