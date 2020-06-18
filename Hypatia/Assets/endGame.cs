using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class endGame : MonoBehaviour
{
    public bool runOnce = false;
    public CanvasGroup endGameGroup;
    float canvasAlpha = 0;

    private void OnTriggerEnter(Collider other)
    {
        if (other.name == "CharacterController" && !runOnce)
        {
            runOnce = true;
        }
    }

    private void Update()
    {
        if (runOnce)
        {
            canvasAlpha += Time.deltaTime;
            Mathf.Clamp(canvasAlpha, 0, 1);
            endGameGroup.alpha = canvasAlpha;
            if (Input.GetKeyDown(KeyCode.R))
                Health.health = 5;
                SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        }
    }
}
