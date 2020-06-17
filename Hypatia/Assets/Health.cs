using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Health : MonoBehaviour
{
    public Slider HealthSlider;
    public static int health = 5;

    // Update is called once per frame
    void Update()
    {
        HealthSlider.value = health;
    }
}
