using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundPlaylist : MonoBehaviour
{
    public AudioSource audioSource;
    public AudioClip[] audioClips;

    void Start()
    {
        audioSource.GetComponent<AudioSource>();
        audioSource.loop = false;
    }

    void Update()
    {
        if (!audioSource.isPlaying)
        {
            audioSource.clip = GetRandomClip();
            audioSource.Play();
        }
    }

    private AudioClip GetRandomClip()
    {
        return audioClips[Random.Range(0, audioClips.Length)];
    }
}
