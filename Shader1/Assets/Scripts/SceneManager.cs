using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneManager : MonoBehaviour
{
    int _selected = 0;
    [SerializeField] int _total = 1;
    
    //vento arvore
    [SerializeField] Renderer _renderTree;
    [SerializeField] float[] _treeAddMod = new float[] {0f, 0.075f};
    //velocidade oceano
    [SerializeField] Renderer[] _renderOcean;
    [SerializeField] float[] _oceanSpeed = new float[] {2f, 20f};
    //velocidade noise na frente da tela
    [SerializeField] Renderer _renderNoise;
    [SerializeField] float[] _noiseScale = new float[] {50f, 200f};
    //mistura dos arco iris do plano no fundo
    [SerializeField] Renderer _renderRainbow;
    [SerializeField] float[] _rainbowMix = new float[] {1f, 5f};

    void Update()
    {
        if(Input.anyKeyDown)
        {
            _selected++;
            if(_selected > _total) _selected = 0;

            _renderTree.material.SetFloat("_WindAddMod", _treeAddMod[_selected]);
            foreach(Renderer rnd in _renderOcean)
                rnd.material.SetFloat("_WaveSpeed", _oceanSpeed[_selected]);
            _renderNoise.material.SetFloat("_NoiseScale", _noiseScale[_selected]);
            _renderRainbow.material.SetFloat("_RainbowMixMod", _rainbowMix[_selected]);
        }
    }
}
