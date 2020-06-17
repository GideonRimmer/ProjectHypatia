using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class endGame : MonoBehaviour
{
    bool runOnce = false;
    bool gameEnded = false;
    public CanvasGroup endGameGroup;

    private void OnTriggerEnter(Collider other)
    {
        if (other.name == "CharacterController" && !runOnce)
        {
            gameEnded = true;
            Mathf.Clamp(endGameGroup.alpha += Time.deltaTime, 0, 1);
            if (endGameGroup.alpha >= .99f)
            {
                runOnce = true;
            }

        }
    }

    private void Update()
    {
        if (gameEnded && Input.GetKeyDown(KeyCode.R))
        {
            SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        }
    }
}
