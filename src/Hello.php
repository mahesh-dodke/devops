<?php

/**
 * A simple class to say hello
 */

namespace Mahesh\Devops;

class Hello
{
    private $name;

    public function __construct($name = 'World')
    {
        $this->name = $name;
    }

    public function getName()
    {
        return $this->name;
    }

    public function hello()
    {
        return 'Hello ' . $this->name . ' from Pre-Prod!';
    }
}
