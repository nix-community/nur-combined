package com.fzakaria.mvn2nix.model;

import com.squareup.moshi.FromJson;
import com.squareup.moshi.JsonDataException;
import com.squareup.moshi.ToJson;

import java.net.MalformedURLException;
import java.net.URL;

public class URLAdapter {

    @ToJson
    public String toJson(URL url) {
        return url.toString();
    }

    @FromJson
    public URL fromJson(String url) {
        try {
            return new URL(url);
        } catch (MalformedURLException e) {
            throw new JsonDataException("Not a valid url", e);
        }
    }
}
