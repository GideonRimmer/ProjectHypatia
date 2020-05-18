using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenuController : MonoBehaviour
{
    public String gameSceneName;
    public String creditsSceneName;

    public void PlayGame()
    {
        SceneManager.LoadScene(gameSceneName);
    }

    public void OpenCreditsMenu()
    {
        SceneManager.LoadScene(creditsSceneName);
    }

    public void QuitGame()
    {
        Debug.Log("Quit!");
        Application.Quit();
    }
}
