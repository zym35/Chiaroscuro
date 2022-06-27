using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Transition : MonoBehaviour
{
    public CanvasGroup canvasGroup;
    public TMP_Text text;

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Application.Quit();
        }
    }

    public void Transit(int toSceneId)
    {
        StartCoroutine(StartTransition(toSceneId));
    }

    private IEnumerator StartTransition(int toSceneId)
    {
        GetComponent<AudioSource>().Play();
        text.text = toSceneId switch
        {
            1 => "<i>- Chapter 1 -</i>\nThe Doors",
            2 => "<i>- Chapter 2 -</i>\nThe Prison",
            3 => "<i>- Thanks for playing -\nTo be Continued...</i>",
            _ => text.text
        };

        canvasGroup.DOFade(1, 1);
        yield return new WaitForSeconds(1);

        if (toSceneId == 2)
            SceneManager.LoadScene(1);

        if (toSceneId != 3)
        {
            yield return new WaitForSeconds(1);
            canvasGroup.DOFade(0, 1);
        }
    }
}